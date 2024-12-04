resource "aws_subnet" "mc_vpc_subnet" {
  vpc_id     = aws_vpc.mc_vpc.id
  cidr_block = var.SUBNET_CIDR_BLOCK
}