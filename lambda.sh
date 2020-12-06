if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage : ./build.sh <lambda code directory> <lambda function Name> [aws profile]";
  exit 1;
fi

lambda=${2%/}; # Removes trailing slashes
directory=${1%/}; # Removes trailing slashes
profile=${3%/};

echo "Deploying $lambda";

cd $directory;
if [ $? -eq 0 ]; then
  echo "...."
else
  echo "Couldn't cd to directory $lambda. You may have mis-spelled the lambda/directory name";
  exit 1
fi

echo "nmp installing...";
npm install
if [ $? -eq 0 ]; then
  echo "done";
else 
  echo "npm install failed";
  exit 1;
fi

echo "Checking that aws-cli is installed"
which aws
if [ $? -eq 0 ]; then
  echo "aws-cli is installed, continuing..."
else
  echo "You need aws-cli to deploy this lambda. Google 'aws-cli install'"
  exit 1
fi

echo "removing old zip"
rm archive.zip;

echo "creating a new zip file"
zip archive.zip *  -r -x .git/\* \*.sh tests/\* node_modules/aws-sdk/\* \*.zip

echo "Uploading $lambda to $region";

if [ -z $profile ]; then
  aws lambda update-function-code --function-name $lambda --zip-file fileb://archive.zip --no-publish --region eu-west-1
else
  aws lambda update-function-code --function-name $lambda --zip-file fileb://archive.zip --no-publish --region eu-west-1 --profile $profile
fi

if [ $? -eq 0 ]; then
  echo "!! Upload successful !!"
else 
  echo "Upload failed"
  echo "If the error was a 400, check that there are no slashes in your lambda name"
  echo "Lambda name = $lambda"
  echo "Also make sure you have the correct default AWS account or use a profile instead"
  exit 1;
fi

rm archive.zip