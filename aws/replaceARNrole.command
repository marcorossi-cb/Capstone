EXTRACT=$(aws cloudformation describe-stacks --stack-name eksctl-capstonecluster-nodegroup-standard-workers --region us-west-2 | grep arn:aws:iam::679871574158:role/eksctl-capstonecluster-nodegroup-NodeInstanceRole- | sed 's/.*"\(.*\)"[^"]*$/\1/')
echo $EXTRACT
sed -ie 's@arn:aws:iam::.*@'"$EXTRACT"'@' aws-auth-cm.yaml
rm -rfv aws-auth-cm.yamle