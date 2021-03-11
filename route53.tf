# Creazione zona pubblica
resource "aws_route53_zone" "public" {
  name = var.domain
  comment = null
}

# Creazione zona interna
resource "aws_route53_zone" "private" {
  name = var.private_domain
  comment = null

  vpc {
    vpc_id = aws_vpc.wordpress-vpc.id
  }
}

# Creazione record database
resource "aws_route53_record" "database" {
  depends_on = [ aws_db_instance.wordpress ]
  zone_id = aws_route53_zone.private.zone_id
  name = "wordpress.db.internal.provapratica.com"
  type = "CNAME"
  ttl = "60"
  records = [aws_db_instance.wordpress.address]
}

# Creazione record www.
resource "aws_route53_record" "www" {
  depends_on = [aws_autoscaling_attachment.asg_attachment_alb]
  zone_id = aws_route53_zone.public.zone_id
  name    = var.wp_url
  type    = "A"
  alias {
    name                   = aws_alb.wp-elb.dns_name
    zone_id                = aws_alb.wp-elb.zone_id
    evaluate_target_health = false
  }
}