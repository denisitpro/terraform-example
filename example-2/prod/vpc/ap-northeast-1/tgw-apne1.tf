resource "aws_ec2_transit_gateway" "c1_prod_apne1_tgw" {
  description                     = "${var.c1_stand}-${var.c1_region_code} transit gateway for VPC connectivity"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name      = "${var.c1_stand}-${var.c1_region_code} TGW"
    Code      = var.c1_company_code
    Createdby = local.c1_author_devops
  }
}

/* attachment internal VPC */
resource "aws_ec2_transit_gateway_vpc_attachment" "c1_prod_apne1_vpc_attach" {
  #  count              = 1
  #  subnet_ids         = [aws_subnet.c1_prod_apne1_public_subnets[count.index].id]
  subnet_ids         = [for s in aws_subnet.c1_prod_apne1_public_subnets : s.id]
  transit_gateway_id = aws_ec2_transit_gateway.c1_prod_apne1_tgw.id
  vpc_id             = aws_vpc.c1_prod_apne1.id

  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name      = "${var.c1_stand}-${var.c1_region_code} VPC attach "
    Code      = var.c1_company_code
    Createdby = local.c1_author_devops
  }
}

##/* attachment c1-prod-apne1 */
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "c1_prod_apne1_attach_accepter_c1_prod_apne1" {
  transit_gateway_attachment_id = var.c1_prod_euc1_to_c1_prod_apne1_attach_accepter

  tags = {
    Name      = "${var.c1_stand}-${var.c1_region_code} accepter c1-prod-euc1"
    Code      = var.c1_company_code
    Createdby = local.c1_author_devops
  }
}

resource "aws_ec2_transit_gateway_route_table" "c1_prod_apne1_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.c1_prod_apne1_tgw.id
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name      = "${var.c1_stand}-${var.c1_region_code} route table"
    Code      = var.c1_company_code
    Createdby = local.c1_author_devops
  }
}
######
resource "aws_ec2_transit_gateway_route" "c1_prod_apne1_to_c1_infra_euc1_g2_route" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.c1_prod_apne1_rt.id
  destination_cidr_block         = "10.99.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.c1_prod_apne1_attach_accepter_c1_prod_apne1.id
}

resource "aws_ec2_transit_gateway_route" "c1_prod_apne1_to_c1_infra_wg_euc1_route" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.c1_prod_apne1_rt.id
  destination_cidr_block         = "10.19.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.c1_prod_apne1_attach_accepter_c1_prod_apne1.id
}

resource "aws_ec2_transit_gateway_route" "c1_prod_apne1_to_c1_prod_euw1_route" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.c1_prod_apne1_rt.id
  destination_cidr_block         = "10.201.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.c1_prod_apne1_attach_accepter_c1_prod_apne1.id
}

/* network provider route support */
#resource "aws_ec2_transit_gateway_route" "c1_prod_apne1_to_provider_vpc_apne1" {
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.c1_prod_apne1_rt.id
#  destination_cidr_block         = "10.200.1.0/24"
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c1_prod_apne1_vpc_attach.id
#}


/*  association section */
resource "aws_ec2_transit_gateway_route_table_association" "c1_prod_apne1_to_c1_prod_euc1_assoc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.c1_prod_apne1_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.c1_prod_apne1_attach_accepter_c1_prod_apne1.id
}

resource "aws_ec2_transit_gateway_route_table_association" "c1_prod_apne1_to_c1_prod_vpc_assoc" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.c1_prod_apne1_rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.c1_prod_apne1_vpc_attach.id
}



output "tgw_id" {
  value = aws_ec2_transit_gateway.c1_prod_apne1_tgw.id
}
