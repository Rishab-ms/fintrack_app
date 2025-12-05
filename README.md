

# FinTrack

FinTrack is a smart, personal finance Flutter application designed to help users track expenses, manage income, and stay within their budgets. Built with a focus on clean architecture, it utilizes **Riverpod** for robust state management and **Hive** for fast, local offline persistence.

## 📱 Screenshots

| | | | |
|:---:|:---:|:---:|:---:|
| <img width="200" src="https://github.com/user-attachments/assets/f72f9f33-3aea-46f0-8875-c7345d62fd57" /> | <img width="200" src="https://github.com/user-attachments/assets/f64c604c-9917-490e-a706-e6b2f0d0bb5c" /> | <img width="200" src="https://github.com/user-attachments/assets/ed77fa9e-2c70-4609-8415-b96940546dd0" /> | <img width="200"  src="https://github.com/user-attachments/assets/ea736021-4bae-4759-86ae-e71ea13f01c0" /> |

-----

## ✨ Features

  * **Smart Dashboard:**
      * Real-time view of Current Balance, Monthly Income, and Monthly Expenses.
      * Interactive Pie Chart (using `fl_chart`) visualizing expense distribution by category.
      * Quick view of recent transactions.
  * **Comprehensive Transaction Tracking:**
      * Track both **Income** and **Expenses**.
      * Transactions grouped chronologically by month.
      * Color-coded amounts (Green for Income, Red for Expense).
  * **Budget Management:**
      * Set monthly spending limits for specific expense categories (Food, Travel, Bills, etc.).
      * Visual progress indicators show percentage used vs. amount left.
      * **Smart Alerts:** Visual warnings when spending exceeds 80% of the budget.
  * **Local Persistence:** Data is stored locally using **Hive**, ensuring the app works completely offline with zero latency.

## 🛠 Tech Stack

  * **Framework:** Flutter
  * **Language:** Dart
  * **State Management:** [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod) (with `riverpod_generator`)
  * **Local Database:** [Hive](https://www.google.com/search?q=https://pub.dev/packages/hive)
  * **Charting:** [fl\_chart](https://pub.dev/packages/fl_chart)
  * **Formatting:** [intl](https://pub.dev/packages/intl)

## 📂 Architecture

The project follows a modular, feature-based architecture to ensure scalability and maintainability.

```text
lib/
├── core/                   # Global components
│   ├── data/               # Hive models, Services, Repositories
│   ├── providers/          # Global Riverpod providers
│   └── shared/             # Utils, Constants (Enums), Widgets
├── features/               # Feature-specific code
│   ├── home/               # Bottom Navigation management
│   ├── dashboard/          # Dashboard UI & Providers
│   ├── transactions/       # Transaction List & Add Modal
│   └── budgets/            # Budget UI & Providers
└── main.dart               # Entry point & App Configuration
```

## 🚀 Getting Started

### Prerequisites

  * Flutter SDK
  * Dart SDK

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/fintrack-v2.git
    cd fintrack-v2
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run Code Generation:**
    Since this project uses `freezed`, `hive_generator`, and `riverpod_generator`, you must run the build runner to generate the necessary code:

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App:**

    ```bash
    flutter run
    ```

## 🧪 Testing

The project includes unit and widget tests for core logic (balance calculations) and UI components (add transaction form).

To run tests:

```bash
flutter test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.
