{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        },
        "DateGreaterThan": {
          "aws:CurrentTime": "2020-06-18T00:00:00Z"
        },
        "IpAddress": {
          "aws:SourceIp": "3.235.186.225/32"
        },
        "DateLessThan": {
          "aws:CurrentTime": "2021-10-30T23:59:59Z"
        }
      },
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::partyparrots-1b6dc4a0",
      "Effect": "Allow"
    },
    {
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        },
        "DateGreaterThan": {
          "aws:CurrentTime": "2020-06-18T00:00:00Z"
        },
        "IpAddress": {
          "aws:SourceIp": "3.235.186.225/32"
        },
        "DateLessThan": {
          "aws:CurrentTime": "2021-10-30T23:59:59Z"
        }
      },
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::partyparrots-1b6dc4a0/Engineering/${aws:username}/*",
      "Effect": "Allow"
    },
    {
      "Condition": {
        "StringEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        },
        "IpAddress": {
          "aws:SourceIp": "3.235.186.225/32"
        }
      },
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::partyparrots-1b6dc4a0/Engineering/encrypted/*",
      "Effect": "Allow"
    }
  ]
}
