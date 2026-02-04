output "public_ip" {
  value = module.ec2.public_ip
}

output "strapi_url" {
  value = "http://${module.ec2.public_ip}:1337/admin"
}
