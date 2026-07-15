# AWS Cloud Monitoring & Alerting with CloudWatch and SNS

> Detect problems early: **CloudWatch metrics & alarms -> SNS -> email/SMS notifications**

This project sets up proactive monitoring and alerting for AWS resources.
CloudWatch collects metrics and logs, alarms watch key thresholds (CPU, status
checks, custom metrics), and when an alarm fires it publishes to an SNS topic
that fans out notifications to subscribed email addresses.

---

## Skills Demonstrated
- **Amazon CloudWatch** — metrics, alarms, dashboards
- **CloudWatch Logs** — log groups and retention
- **Amazon SNS** — topics and subscriptions for notifications
- **Monitoring & Alerting** — threshold-based alarms
- **Logging** — centralized log collection

---

## Flow

```
  EC2 / Lambda / RDS
        |
        v
  CloudWatch Metrics + Logs
        |
   (threshold breached)
        v
  CloudWatch Alarm  ---- ALARM ---->  SNS Topic
                                          |
                          +---------------+---------------+
                          v                               v
                    Email subscriber              (optional) SMS / Lambda
```

---

## Repository Structure
```
.
├── cloudformation/
│   └── monitoring.yaml   # SNS topic + subscription + CloudWatch alarms
├── scripts/
│   └── setup-monitoring.sh  # Same setup using AWS CLI
└── README.md
```

---

## Deploy with CloudFormation
```bash
aws cloudformation create-stack \\
  --stack-name monitoring \\
  --template-body file://cloudformation/monitoring.yaml \\
  --parameters ParameterKey=NotifyEmail,ParameterValue=you@example.com \\
               ParameterKey=InstanceId,ParameterValue=i-0123456789abcdef0
```
Confirm the SNS subscription via the email you receive, then alarms will notify you.

## Cleanup
```bash
aws cloudformation delete-stack --stack-name monitoring
```

---

## Author
**Dipak Kuthe** — DevOps / Cloud Engineer
