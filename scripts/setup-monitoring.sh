#!/bin/bash
# ---------------------------------------------------------------------------
# Set up CloudWatch alarms + SNS notifications using the AWS CLI.
# Usage: ./setup-monitoring.sh <notify-email> <instance-id>
# ---------------------------------------------------------------------------
set -euo pipefail

NOTIFY_EMAIL="${1:?Provide an email address}"
INSTANCE_ID="${2:?Provide an EC2 instance id}"
TOPIC_NAME="monitoring-alerts"

echo "Creating SNS topic..."
TOPIC_ARN=$(aws sns create-topic --name "$TOPIC_NAME" --query TopicArn --output text)

echo "Subscribing $NOTIFY_EMAIL (confirm via email)..."
aws sns subscribe \\
  --topic-arn "$TOPIC_ARN" \\
  --protocol email \\
  --notification-endpoint "$NOTIFY_EMAIL"

echo "Creating high CPU alarm..."
aws cloudwatch put-metric-alarm \\
  --alarm-name "ec2-high-cpu" \\
  --alarm-description "CPU > 80% for 10 minutes" \\
  --namespace "AWS/EC2" \\
  --metric-name "CPUUtilization" \\
  --statistic Average \\
  --period 300 \\
  --evaluation-periods 2 \\
  --threshold 80 \\
  --comparison-operator GreaterThanThreshold \\
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \\
  --alarm-actions "$TOPIC_ARN"

echo "Creating status-check alarm..."
aws cloudwatch put-metric-alarm \\
  --alarm-name "ec2-status-check-failed" \\
  --alarm-description "Instance status check failed" \\
  --namespace "AWS/EC2" \\
  --metric-name "StatusCheckFailed" \\
  --statistic Maximum \\
  --period 60 \\
  --evaluation-periods 2 \\
  --threshold 1 \\
  --comparison-operator GreaterThanOrEqualToThreshold \\
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \\
  --alarm-actions "$TOPIC_ARN"

echo "Done. Confirm the SNS subscription in your email inbox."
