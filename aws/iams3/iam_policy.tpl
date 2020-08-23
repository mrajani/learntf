{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "${region}"
        },
        "DateGreaterThan": {
          "aws:CurrentTime": "2020-06-18T00:00:00Z"
        },
        "IpAddress": {
          "aws:SourceIp": "${src_ip}"
        },
        "DateLessThan": {
          "aws:CurrentTime": "2021-10-30T23:59:59Z"
        }
      },
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::${bucket}",
      "Effect": "Allow"
    },
    {
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "${region}"
        },
        "DateGreaterThan": {
          "aws:CurrentTime": "2020-06-18T00:00:00Z"
        },
        "IpAddress": {
          "aws:SourceIp": "${src_ip}"
        },
        "DateLessThan": {
          "aws:CurrentTime": "2021-10-30T23:59:59Z"
        }
      },
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::${bucket}/Engineering/$${aws:username}/*",
      "Effect": "Allow"
    },
    {
      "Condition": {
        "StringEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        },
        "IpAddress": {
          "aws:SourceIp": "${src_ip}"
        }
      },
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::${bucket}/Engineering/encrypted/*",
      "Effect": "Allow"
    }
  ]
}
