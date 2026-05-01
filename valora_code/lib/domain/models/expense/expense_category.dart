enum ExpenseCategory { software, hardware, marketing, services, other }

extension ExpenseCategoryLabel on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.software:
        return 'Software';
      case ExpenseCategory.hardware:
        return 'Hardware';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.services:
        return 'Servicios';
      case ExpenseCategory.other:
        return 'Otro';
    }
  }
}
