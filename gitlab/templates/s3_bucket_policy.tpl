{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Action": "s3:ListBucket",
			"Principal": "*",
			"Resource": "arn:aws:s3:::${bucket}",
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
			}
		},
		{
			"Effect": "Allow",
			"Principal": "*",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:DeleteObject"
			],
			"Resource": "arn:aws:s3:::${bucket}/*",
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
			}
		},
		{
			"Effect": "Allow",
			"Principal": "*",
			"Action": "s3:PutObject",
			"Resource": "arn:aws:s3:::${bucket}/*",
			"Condition": {
				"StringEquals": {
					"s3:x-amz-server-side-encryption": "AES256"
				},
				"IpAddress": {
					"aws:SourceIp": "${src_ip}"
				}
			}
		}
	]
}