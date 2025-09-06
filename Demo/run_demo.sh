#!/bin/bash
set -e

# Add a trap to catch errors and display a message
trap 'echo -e "${RED}❌ An error occurred. Exiting...${NO_COLOR}"' ERR

clear

# # Step 0: Install kind (Kubernetes in Docker) if not already installed
# if ! command -v kind &> /dev/null
# then
#     echo "kind could not be found, installing..."
# fi
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-darwin-amd64
# chmod +x ./kind
# mv ./kind /usr/local/bin/kind

# Load the colors palette
# Load the colors palette - Download the colors script
temp_file=$(mktemp)         &&  \
            curl -s https://raw.githubusercontent.com/nirgeier/labs-assets/refs/heads/main/assets/scripts/colors.sh \
            -o "$temp_file" &&  \
            source "$temp_file"
echo -e "${GREEN}🌈 Colors palette loaded.${NO_COLOR}"

# DevOps Demo Script
echo -e "${YELLOW}🚀 Starting DevOps demo...${NO_COLOR}"
echo -e "${YELLOW}---------------------------------------------------------------${NO_COLOR}"

# Get the root directory of the script
ROOT_DIR=$(dirname "$0")

# Test that we have K8s cluster access
if ! kubectl cluster-info &> /dev/null
then
  echo -e "${RED}❌ Cannot access Kubernetes cluster. Please ensure your kubeconfig is set up correctly.${NO_COLOR}"
  exit 1
fi
echo -e "${GREEN}☸️  Kubernetes cluster exists.${NO_COLOR}"

# Step 1: Build and run Docker Compose

# Check if we have docker
if ! command -v docker &> /dev/null
then
    echo -e "${RED}❌ Docker could not be found, please install Docker.${NO_COLOR}"
    exit 1
fi
echo -e "${GREEN}🐳 Docker is installed.${NO_COLOR}"

# Check if we have docker-compose
if ! command -v docker-compose &> /dev/null
then
    echo -e "${RED}❌ docker-compose could not be found, please install docker  -compose.${NO_COLOR}"
    exit 1
fi

echo -e "${GREEN}🐳 docker-compose is installed.${NO_COLOR}"
if [ -f docker/docker-compose.yml ]; then
  echo "Building and running Docker Compose..."
  docker-compose -f docker/docker-compose.yml up --build -d
else
  echo -e "${RED}❌ docker-compose.yml not found!${NO_COLOR}"
fi


# Step 2: Run tests
if [ -f docker/docker-compose.yml ]; then
  echo "Installing dependencies and running tests..."
  # Run the container to execute tests
  docker run --rm docker-app
else
  echo -e "${RED}❌ docker-compose.yml not found!${NO_COLOR}"
fi

# Step 3: Create local Kubernetes cluster with Terraform
cd terraform
if [ -f main.tf ]; then
  echo "Initializing and applying Terraform for k8s..."
  terraform init
  terraform apply -auto-approve
else
  echo "main.tf not found!"
fi
cd ..

# Step 4: Build Docker image for k8s
cd src
if [ -f app.js ]; then
  echo "Building Docker image for k8s..."
  docker build -t devops-demo:latest .
else
  echo "app.js not found!"
fi
cd ..

# Step 5: Deploy with Helm
cd helm
if [ -f Chart.yaml ]; then
  echo "Deploying app with Helm..."
  helm install devops-demo . --set image.repository=devops-demo --set image.tag=latest || helm upgrade devops-demo . --set image.repository=devops-demo --set image.tag=latest
else
  echo "Chart.yaml not found!"
fi
cd ..

# Step 6: Deploy with ArgoCD
# Install ArgoCD if not already installed
if ! kubectl get crd applications.argoproj.io &> /dev/null; then
  echo "Installing ArgoCD..."
  kubectl create namespace argocd || true
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  echo "Waiting for ArgoCD to be ready..."
  kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n argocd || echo "ArgoCD may still be starting up..."
else
  echo "ArgoCD is already installed"
fi

if [ -f argocd/devops-demo-app.yaml ]; then
  echo "Applying ArgoCD manifest..."
  kubectl apply -f argocd/devops-demo-app.yaml || echo "ArgoCD application manifest applied (may sync later)"
else
  echo "ArgoCD manifest not found!"
fi

# Step 7: Install Prometheus & Grafana
if [ -f monitoring/prometheus-stack-values.yaml ]; then
  echo "Installing Prometheus & Grafana with Helm..."
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm install monitoring prometheus-community/kube-prometheus-stack -f monitoring/prometheus-stack-values.yaml || helm upgrade monitoring prometheus-community/kube-prometheus-stack -f monitoring/prometheus-stack-values.yaml
else
  echo "Prometheus stack values not found!"
fi

# Step 8: Simulate errors
cd argocd/automation
if [ -f error_simulation.js ]; then
  echo "Simulating errors..."
  npm install axios || true
  node error_simulation.js
else
  echo "error_simulation.js not found!"
fi

# Step 9: Run ticket automation
if [ -f ticket_automation.js ]; then
  if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not set. Skipping ticket automation."
  else
    npm install octokit || true
    echo "Running ticket automation..."
    node ticket_automation.js
  fi
else
  echo "ticket_automation.js not found!"
fi
cd ..

# Step 10: Reminder for Grafana dashboard import
if [ -f monitoring/grafana-dashboard.json ]; then
  echo "Please import monitoring/grafana-dashboard.json into Grafana manually."
fi

# Step 11: Documentation
if [ -d doc ]; then
  echo "Documentation is available in the /doc folder:"
  ls doc
else
  echo "/doc folder not found!"
fi

echo "DevOps demo execution complete!"
