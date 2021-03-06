# BACKOFFICE subnets
resource "aws_subnet" "subn_backoffice" {
  # one for each az
  count             = length(var.az_postfixes)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = "${var.ip_prefix}.${140 + count.index}.0/24"
  availability_zone = "${var.region}${element(var.az_postfixes, count.index)}"

  tags = {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes, count.index)}-${var.env_name}-SUBN-backoffice"
  }
}

# route-table for the backoffice subnets
resource "aws_route_table" "rtb_backoffice" {
  vpc_id = aws_vpc.vpc_main.id

  # one for each az
  count = length(var.az_postfixes)

  tags = {
    Name = "MNG-${var.stack_name}-${var.region}${element(var.az_postfixes, count.index)}-${var.env_name}-RTB-backoffice"
  }
}

# association between the backoffice subnets and the backoffice routetable
resource "aws_route_table_association" "rtassoc_backoffice" {
  # one for each az
  count          = length(var.az_postfixes)
  subnet_id      = element(aws_subnet.subn_backoffice.*.id, count.index)
  route_table_id = element(aws_route_table.rtb_backoffice.*.id, count.index)
}

# this is the route to the egress_aws natgateway
resource "aws_route" "r_backoffice_egress_aws_ngw" {
  # one for each az
  count                  = length(var.az_postfixes)
  route_table_id         = element(aws_route_table.rtb_backoffice.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw_egress_aws.*.id, count.index)
}

