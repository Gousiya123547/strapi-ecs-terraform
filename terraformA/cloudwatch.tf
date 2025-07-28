resource "aws_cloudwatch_metric_alarm" "high_cpu_kg" {
  alarm_name          = "strapi-high-cpu-kg"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Triggers when ECS CPU > 70%"
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_kg.name
    ServiceName = aws_ecs_service.strapi_kg.name
  }
}

