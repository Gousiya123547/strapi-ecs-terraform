resource "aws_cloudwatch_metric_alarm" "high_cpu_kg" {
  alarm_name          = "strapi-high-cpu-kg"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers when ECS CPU usage exceeds 80%"
  actions_enabled     = true

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_kg.name
    ServiceName = data.aws_ecs_service.strapi_kg.service_name
  }
}

