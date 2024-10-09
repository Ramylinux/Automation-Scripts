# Automated Backup to Amazon S3

This project provides an automated solution to back up files to an Amazon S3 bucket using a script executed on an EC2 instance. The process includes creating a new user, assigning permissions, and using a YAML script to upload backups automatically.
# Requirements

   - Amazon S3 Bucket: For storing backups
   - IAM User: To interact with the S3 service
   - IAM Role: For EC2 instances to use S3 and Systems Manager (SSM)
   - EC2 Instance: To run the backup script

# Setup
### 1. Create an IAM User with S3 Access

Create an IAM user (s3-bash-user) to access the S3 bucket.

<div class="flex items-center text-token-text-secondary bg-token-main-surface-secondary px-4 py-2 text-xs font-sans justify-between rounded-t-md h-9">bash</div>
<div class="overflow-y-auto p-4" dir="ltr">
<code class="!whitespace-pre hljs language-bash">
aws iam create-user --user-name s3-bash-user
aws iam attach-user-policy --user-name s3-bash-user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
</code>
</div>

### 2. Create an IAM Role for EC2 Instance

Create an IAM role (s3-bash-role) with the necessary permissions for S3 and Systems Manager.

<div class="dark bg-gray-950 contain-inline-size rounded-md border-[0.5px] border-token-border-medium relative"><div class="flex items-center text-token-text-secondary bg-token-main-surface-secondary px-4 py-2 text-xs font-sans justify-between rounded-t-md h-9">bash</div><div class="sticky top-9 md:top-[5.75rem]">
  <div class="absolute bottom-0 right-2 flex h-9 items-center">
    <div class="flex items-center rounded bg-token-main-surface-secondary px-2 font-sans text-xs text-token-text-secondary">
      <span class="" data-state="closed">
        <button class="flex gap-1 items-center py-1">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="icon-sm">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M7 5C7 3.34315 8.34315 2 10 2H19C20.6569 2 22 3.34315 22 5V14C22 15.6569 20.6569 17 19 17H17V19C17 20.6569 15.6569 22 14 22H5C3.34315 22 2 20.6569 2 19V10C2 8.34315 3.34315 7 5 7H7V5ZM9 7H14C15.6569 7 17 8.34315 17 10V15H19C19.5523 15 20 14.5523 20 14V5C20 4.44772 19.5523 4 19 4H10C9.44772 4 9 4.44772 9 5V7ZM5 9C4.44772 9 4 9.44772 4 10V19C4 19.5523 4.44772 20 5 20H14C14.5523 20 15 19.5523 15 19V10C15 9.44772 14.5523 9 14 9H5Z" fill="currentColor"></path></svg>
         </button></span></div></div></div>
  <div class="overflow-y-auto p-4" dir="ltr">
  <code class="!whitespace-pre hljs language-bash">aws iam create-role --role-name s3-bash-role --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --role-name s3-bash-role --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name s3-bash-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMFullAccess
</code></div></div>


#### The trust policy (trust-policy.json) should allow EC2 to assume this role:

json

<div class="overflow-y-auto p-4" dir="ltr"><code class="!whitespace-pre hljs language-json"><span class="hljs-punctuation">{</span>
    <span class="hljs-attr">"Version"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"2012-10-17"</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"Statement"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span>
        <span class="hljs-punctuation">{</span>
            <span class="hljs-attr">"Effect"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"Allow"</span><span class="hljs-punctuation">,</span>
            <span class="hljs-attr">"Principal"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
                <span class="hljs-attr">"Service"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"ec2.amazonaws.com"</span>
            <span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
            <span class="hljs-attr">"Action"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"sts:AssumeRole"</span>
        <span class="hljs-punctuation">}</span>
    <span class="hljs-punctuation">]</span>
<span class="hljs-punctuation">}</span>
</code></div>

### 3. Attach the IAM Role to the EC2 Instance

Ensure that the role is attached to your EC2 instance:

   1. Go to the EC2 Dashboard.
   2. Select the instance you want to use.
   3. Under Actions, select Security → Modify IAM Role.
   4. Attach the s3-bash-role to the instance.

### 4. YAML Script for Backup

Here's a sample YAML script to upload files to the S3 bucket.

yaml

<div class="overflow-y-auto p-4" dir="ltr">
<code class="!whitespace-pre hljs language-yaml">
<span class="hljs-attr">version:</span> <span class="hljs-string">'2.0'</span>
   <span class="hljs-attr">actions:</span> 
   <span class="hljs-string">"Upload backup to S3"</span>
    <span class="hljs-attr">name:</span>
   <span class="hljs-string">"Project-1-AWS-Auto-Backup-AWS-Script 2"</span>
   <span class="hljs-attr">script:</span>

<span class="hljs-string">|
#!/bin/bash
time=$(date +%m-%d-%y_%H_%M_%S)
Backup_file=/home/ubuntu/bash
Dest=/home/ubuntu/backup
filename=file-backup-$time.tar.gz
LOG_FILE="/home/ubuntu/backup/logfile.log"

S3_BUCKET="s3-new-bash-course"
FILE_TO_UPLOAD="$Dest/$filename"


if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install it first."
  exit 2
fi

if [ $? -ne 2 ]
  then
  if [ -f $filename ]
  then
      echo "Error file $filename already exist!" | tee -a "$LOG_FILE"
  else
      tar -czvf "$Dest/$filename" "$Backup_file" 
      echo "Backup completed successfully. Backup file: $Dest/$filename " | tee -a "$LOG_FILE"
      echo
      aws s3 cp "$FILE_TO_UPLOAD" "s3://$S3_BUCKET/"
  fi
fi

if [ $? -eq 0 ]; then
  echo
  echo "File uploaded successfully to the S3 bucket: $S3_BUCKET"
else
  echo "File upload to S3 failed."
fi
</span>

</code>
</div>

### 5. Automating the Backup with EC2

Once the EC2 instance has the role and permissions, you can use AWS Systems Manager (SSM) to run this script on the instance. Set up a cron job on the instance to execute the YAML-based script at regular intervals.
Example Cron Job

bash

<div class="overflow-y-auto p-4" dir="ltr"><code class="!whitespace-pre hljs language-bash">crontab -e
</code></div>

# Add the following line to schedule the backup at midnight every day:

bash

<code class="!whitespace-pre hljs language-bash">0 0 * * * /path/to/your-backup-script.sh
</code>
