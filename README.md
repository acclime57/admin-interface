
# Document Management System

A Next.js application for managing and chatting with documents using AI. This application can be deployed as a static website to Amazon S3.

## Envirenement Variable setup

Before running the project set the backend Url in the .env file 

```
NEXT_PUBLIC_API_URL=your-url
```

## Local Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev
```

## Building for Production

To create a static build for S3 deployment:

```bash
# Install dependencies if not already done
npm install

# Create production build
npm run build
```

This will create an `out` directory containing the static website files ready for S3 deployment.

## Deploying to S3

### Manual Deployment

1. Create an S3 bucket:
   - Go to AWS Console > S3
   - Create a new bucket
   - Enable "Static website hosting" in bucket properties
   - Configure bucket policy for public access:
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Sid": "PublicReadGetObject",
               "Effect": "Allow",
               "Principal": "*",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::your-bucket-name/*"
           }
       ]
   }
   ```

2. Upload the contents of the `out` directory to your S3 bucket:
   - Upload all files from the `out` directory to your S3 bucket
   - Set appropriate cache headers:
     - For `index.html`: `Cache-Control: no-cache`
     - For other files: `Cache-Control: public, max-age=31536000, immutable`

### Using AWS CLI

If you have AWS CLI configured, you can use these commands:

```bash
# Deploy to S3
aws s3 sync out/ s3://your-bucket-name --delete

# Update cache headers for index.html
aws s3 cp s3://your-bucket-name/index.html s3://your-bucket-name/index.html \
    --metadata-directive REPLACE \
    --cache-control "no-cache"
```

### Automated Deployment

This project includes GitHub Actions workflow for automated deployments. To use it:

1. Configure GitHub repository secrets:
   ```
   AWS_ACCESS_KEY_ID=your-access-key
   AWS_SECRET_ACCESS_KEY=your-secret-key
   NEXT_PUBLIC_API_URL=your-api-url
   ```

2. Push to main branch or manually trigger the workflow from GitHub Actions tab

## Environment Variables

Create a `.env.local` file for local development:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

For production, update the URL to your actual API endpoint.

## Accessing the Website

After deployment, your website will be available at:
```
http://your-bucket-name.s3-website.your-region.amazonaws.com
```

For production use, it's recommended to set up CloudFront for HTTPS and better performance.

## Features

- Document management
- AI-powered chat interface
- Static hosting compatible
- Persistent chat history
- Responsive design

## Tech Stack

- Next.js
- React
- TypeScript
- Tailwind CSS
- Zustand (State Management)
- AWS S3 (Hosting)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
