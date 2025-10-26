String getCategoryImage(String category, String type) {
  switch (category.toLowerCase()) {
    // Expense categories
    case 'food':
      return 'assets/icons/meal.png';
    case 'grocery':
      return 'assets/icons/cart-minus.png';
    case 'rent':
      return 'assets/icons/rent.png';
    case 'taxi':
      return 'assets/icons/vehicles.png';
    case '1 to 10':
      return 'assets/icons/basket.png';
    case 'transfer':
      return 'assets/icons/money-transfer.png';

    // Income categories
    case 'salary':
      return 'assets/icons/wages.png';
    case 'freelance':
      return 'assets/icons/Freelance.png';
    case 'bonus':
      return 'assets/icons/bag.png';

    // Default fallback
    default:
      return type == 'income'
          ? 'assets/icons/income.png'
          : 'assets/icons/expenses.png';
  }
}
