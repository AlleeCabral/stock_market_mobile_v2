class PortfolioHolding {
  final String name;
  final String symbol;
  final String currency;
  final double price;
  final double change;
  int quantity;

  PortfolioHolding({
    required this.name,
    required this.symbol,
    required this.currency,
    required this.price,
    required this.change,
    required this.quantity,
  });

  double get totalValue {
    return price * quantity;
  }
}