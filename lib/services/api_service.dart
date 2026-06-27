import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/marketstack_accounts.dart';

class MarketstackApiException implements Exception {
	final String message;

	const MarketstackApiException(this.message);

	@override
	String toString() => message;
}

class MarketstackConfigurationException extends MarketstackApiException {
	const MarketstackConfigurationException(super.message);
}

class MarketstackQuotaExceededException extends MarketstackApiException {
	const MarketstackQuotaExceededException(super.message);
}

class ApiService {
	ApiService({String? accessKey, List<String>? accessKeys, http.Client? client})
			: _client = client ?? http.Client() {
		final configured = <String>[
			if ((accessKey ?? '').trim().isNotEmpty) accessKey!.trim(),
			...?accessKeys,
			...MarketstackAccounts.activeAccessKeys,
			const String.fromEnvironment('MARKETSTACK_API_KEY'),
		];

		_accessKeys = _dedupeAndClean(configured);
	}

	final http.Client _client;
	final String _baseUrl = 'https://api.marketstack.com/v1';
	final String _baseUrlV2 = 'https://api.marketstack.com/v2';
	late final List<String> _accessKeys;
	int _activeKeyIndex = 0;

	/// Same as [get] but targets the Marketstack v2 API.
	Future<Map<String, dynamic>> getV2(
		String path, {
		Map<String, String>? queryParameters,
	}) => _request(_baseUrlV2, path, queryParameters: queryParameters);

	Future<Map<String, dynamic>> get(
		String path, {
		Map<String, String>? queryParameters,
	}) => _request(_baseUrl, path, queryParameters: queryParameters);

	Future<Map<String, dynamic>> _request(
		String baseUrl,
		String path, {
		Map<String, String>? queryParameters,
	}) async {
		if (_accessKeys.isEmpty) {
			throw const MarketstackConfigurationException(
				'No Marketstack API keys configured. Add keys in lib/config/marketstack_accounts.dart '
				'or pass --dart-define=MARKETSTACK_API_KEY=YOUR_KEY.',
			);
		}

		Object? lastError;
		final totalKeys = _accessKeys.length;
		final startIndex = _activeKeyIndex;

		// Try each account once. If one key hits quota, fall through to the next key.
		for (var i = 0; i < totalKeys; i++) {
			final keyIndex = (startIndex + i) % totalKeys;
			final key = _accessKeys[keyIndex];

			final mergedQuery = <String, String>{
				'access_key': key,
				...?queryParameters,
			};

			final uri = Uri.parse('$baseUrl/$path').replace(queryParameters: mergedQuery);

			try {
				final response = await _client.get(uri);
				final decoded = _decodeBody(response.body);

				if (response.statusCode < 200 || response.statusCode >= 300) {
					if (_looksLikeQuotaError(decoded)) {
						lastError = MarketstackQuotaExceededException(
							'Quota reached for configured Marketstack key #${keyIndex + 1}.',
						);
						continue;
					}
					throw MarketstackApiException(
						'Marketstack request failed (${response.statusCode}): ${response.body}',
					);
				}

				if (decoded.containsKey('error')) {
					if (_looksLikeQuotaError(decoded)) {
						lastError = MarketstackQuotaExceededException(
							'Quota reached for configured Marketstack key #${keyIndex + 1}.',
						);
						continue;
					}
					throw MarketstackApiException('Marketstack API error: ${decoded['error']}');
				}

				// Round-robin on success to spread requests across team accounts.
				_activeKeyIndex = (keyIndex + 1) % totalKeys;
				return decoded;
			} catch (error) {
				lastError = error;
			}
		}

		if (lastError is MarketstackQuotaExceededException) {
			throw MarketstackQuotaExceededException(
				'All configured Marketstack keys reached quota for this request. Last error: $lastError',
			);
		}

		throw MarketstackApiException('All configured Marketstack keys failed. Last error: $lastError');
	}

	Map<String, dynamic> _decodeBody(String body) {
		final decoded = jsonDecode(body);
		if (decoded is! Map<String, dynamic>) {
			throw const MarketstackApiException('Unexpected response format from Marketstack.');
		}
		return decoded;
	}

	bool _looksLikeQuotaError(Map<String, dynamic> payload) {
		final error = payload['error'];
		final text = error?.toString().toLowerCase() ?? '';
		return text.contains('limit') ||
				text.contains('quota') ||
				text.contains('usage') ||
				text.contains('rate');
	}

	List<String> _dedupeAndClean(List<String> rawKeys) {
		final cleaned = rawKeys.map((item) => item.trim()).where((item) => item.isNotEmpty);
		return cleaned.toSet().toList();
	}

	void dispose() {
		_client.close();
	}
}
