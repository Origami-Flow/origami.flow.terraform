resource "aws_key_pair" "generated_key" {
    key_name    = var.aws_access_key
    public_key  = file("mysshkey.pem.pub")
}
