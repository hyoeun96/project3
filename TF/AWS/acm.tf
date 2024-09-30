# 인증서 생성
resource "aws_acm_certificate" "cert" {
    domain_name       = "*.taehoone.shop"
    validation_method = "DNS"

    tags = {
        Name = "aws-cert"
    }

    lifecycle {
        create_before_destroy = true
    }
}

# 인증서 검증
resource "aws_route53_record" "route53_ssl" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.route53.zone_id
}