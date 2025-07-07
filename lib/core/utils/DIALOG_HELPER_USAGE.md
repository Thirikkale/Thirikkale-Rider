# Dialog Helper Usage Guide

The `DialogHelper` utility provides reusable dialog components that maintain consistent styling throughout the app.

## Import

```dart
import 'package:thirikkale_rider/core/utils/dialog_helper.dart';
```

## Available Methods

### 1. Confirmation Dialog

Use for actions that require user confirmation (like delete operations).

```dart
DialogHelper.showConfirmationDialog(
  context: context,
  title: 'Delete Item',
  content: 'Are you sure you want to delete this item?',
  confirmText: 'Delete',
  cancelText: 'Cancel',
  confirmButtonColor: AppColors.error, // Optional
  titleIcon: Icons.delete, // Optional
  onConfirm: () {
    // Handle confirmation
  },
  onCancel: () {
    // Handle cancellation (optional)
  },
);
```

### 2. Checkbox Dialog

Use for options with checkbox selection (like "set as default").

```dart
DialogHelper.showCheckboxDialog(
  context: context,
  title: 'Cash Payment',
  content: 'Pay with cash at the end of your ride.',
  checkboxLabel: 'Set as default payment method',
  titleIcon: Icons.money,
  onConfirm: (isChecked) {
    // Handle confirmation with checkbox state
    if (isChecked) {
      // Set as default
    }
  },
);
```

### 3. Info Dialog

Use for simple informational messages.

```dart
DialogHelper.showInfoDialog(
  context: context,
  title: 'Information',
  content: 'This is an informational message.',
  buttonText: 'Got it', // Optional, defaults to 'OK'
  titleIcon: Icons.info,
  onOk: () {
    // Handle OK button press (optional)
  },
);
```

## Styling Features

- **Consistent Design**: All dialogs follow the app's design system
- **Icon Support**: Add icons to dialog titles
- **Color Customization**: Custom button colors for different actions
- **Text Styling**: Uses app's text styles automatically
- **Responsive Layout**: Proper spacing and alignment

## Real-world Examples

### Delete Confirmation
```dart
void _deletePaymentMethod() {
  DialogHelper.showConfirmationDialog(
    context: context,
    title: 'Delete Payment Method',
    content: 'This action cannot be undone.',
    confirmText: 'Delete',
    confirmButtonColor: AppColors.error,
    onConfirm: () {
      // Perform deletion
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Payment method deleted',
      );
    },
  );
}
```

### Set Default Option
```dart
void _showCashOption() {
  DialogHelper.showCheckboxDialog(
    context: context,
    title: 'Cash Payment',
    content: 'Pay your driver with cash.',
    checkboxLabel: 'Set as default',
    titleIcon: Icons.money,
    onConfirm: (setAsDefault) {
      String message = setAsDefault 
        ? 'Cash set as default!' 
        : 'Cash option selected!';
      SnackbarHelper.showSuccessSnackBar(context, message);
    },
  );
}
```

### Simple Info
```dart
void _showWelcomeMessage() {
  DialogHelper.showInfoDialog(
    context: context,
    title: 'Welcome!',
    content: 'Thanks for using our app.',
    titleIcon: Icons.celebration,
    buttonText: 'Continue',
  );
}
```

## Benefits

1. **Consistency**: All dialogs look and behave the same
2. **Maintainability**: Easy to update styling across the app
3. **Reusability**: One helper for multiple dialog types
4. **Clean Code**: Less boilerplate in individual screens
5. **Type Safety**: Proper callback typing and parameters
