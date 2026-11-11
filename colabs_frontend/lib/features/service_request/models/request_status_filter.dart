enum RequestStatusFilter {
  pending('Pendiente', 'pending'),
  accepted('Aceptado', 'accepted'),
  inProgress('En progreso', 'in_progress'),
  completed('Completado', 'completed');

  const RequestStatusFilter(this.label, this.apiValue);

  final String label;
  final String apiValue;

  bool matches(String status) => status == apiValue;
}
