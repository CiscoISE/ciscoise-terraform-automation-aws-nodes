resource "aws_route53_zone" "forward_dns" {
  name    = var.dns_domain
  comment = "Private hosted forward zone for ISE"
  vpc {
    vpc_id = var.vpcid
  }

  tags = {
    Name = "Forwardzone-${var.dns_domain}"
  }
}

resource "aws_route53_record" "lb_dns_record" {
  zone_id = aws_route53_zone.forward_dns.zone_id
  name    = "lb.${var.dns_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.psn_nlb.dns_name
    zone_id                = aws_lb.psn_nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ise_node_dns_record" {
  for_each = zipmap(local.ise_hostnames_list, local.ise_private_ip_list)
  zone_id  = aws_route53_zone.forward_dns.zone_id
  name     = "${each.key}.${var.dns_domain}"
  type     = "A"
  ttl      = 300
  records  = [each.value]
}

