resource "aws_codedeploy_app" "strapi_app" {
  name             = "strapi-cd-app-${var.env}"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "strapi_dg" {
  app_name               = aws_codedeploy_app.strapi_app.name
  deployment_group_name  = "strapi-cd-dg-${var.env}"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  # ✅ REQUIRED for ECS Blue/Green
  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.strapi_cluster.name
    service_name = aws_ecs_service.strapi_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.strapi_tg_blue.name
      }
      target_group {
        name = aws_lb_target_group.strapi_tg_green.name
      }

      prod_traffic_route {
        listener_arns = [aws_lb_listener.strapi_listener.arn]
      }
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

