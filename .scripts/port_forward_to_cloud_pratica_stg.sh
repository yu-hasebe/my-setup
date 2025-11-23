#!/bin/sh
INSTANCE_ID=$(aws ec2 describe-instances \
	--filters "Name=tag:Name,Values=cp-bastion-stg" "Name=instance-state-name,Values=running" \
	--query "Reservations[0].Instances[0].InstanceId" \
	--output text \
	--profile cp-terraform-stg)

aws ssm start-session \
	--target $INSTANCE_ID \
	--document-name AWS-StartPortForwardingSessionToRemoteHost \
	--parameters '{"host":["cloud-pratica-stg.cvy4cicekwyq.ap-northeast-1.rds.amazonaws.com"],"portNumber":["5432"], "localPortNumber":["15432"]}' \
	--profile cp-terraform-stg
