void _startRental(Scooter scooter) async {
  final auth = Provider.of<AuthService>(context, listen: false);
  
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Підтвердження'),
      content: Text('Розпочати оренду самокату ${scooter.id.substring(0, 8)}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Скасувати'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Підтвердити'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final success = await auth.startRental(
      scooter.id,
      scooter.lat,
      scooter.lng,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оренда розпочата успішно!')),
      );
      _panelController.close();
      _fetchAndShowScooters();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Помилка початку оренди')),
      );
    }
  }
}

void _endRental() async {
  final auth = Provider.of<AuthService>(context, listen: false);
  
  final paymentMethod = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Завершення оренди'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Оберіть спосіб оплати:'),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Банківська картка'),
            onTap: () => Navigator.of(context).pop('CARD'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Бонусний рахунок'),
            onTap: () => Navigator.of(context).pop('BONUS'),
          ),
        ],
      ),
    ),
  );

  if (paymentMethod != null) {
    final success = await auth.endRental(
      _currentUserLat,
      _currentUserLon,
      paymentMethod,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оренда завершена успішно!')),
      );
      _panelController.close();
      _fetchAndShowScooters();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Помилка завершення оренди')),
      );
    }
  }
}
