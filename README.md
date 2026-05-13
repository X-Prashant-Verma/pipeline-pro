# 🚀 PipelinePro

**A production-style CI/CD pipeline that provisions AWS infrastructure with Terraform and automatically deploys a Dockerised Flask app via GitHub Actions.**

> Phase 4 capstone of my Cloud/DevOps learning roadmap — bringing together IaC, containerisation, and automated deployments on real AWS infrastructure.

---

## 🏗️ Architecture

```
GitHub Push
    │
    ▼
GitHub Actions (CI/CD)
    ├── Build & push Docker image → ghcr.io
    └── SSH into EC2 → pull & run latest container
             │
             ▼
        AWS (ap-south-1)
        ├── VPC + Public Subnet
        ├── Internet Gateway + Route Table
        ├── Security Group (ports 22, 80)
        └── EC2 Instance
                │
                ▼
          Flask App (port 5000)
          running in Docker
```

---

## 🛠️ Tech Stack

| Layer | Tool |
|---|---|
| App | Python 3.11 + Flask |
| Containerisation | Docker |
| Infrastructure | Terraform (HCL) |
| CI/CD | GitHub Actions |
| Cloud | AWS EC2, VPC, SG (ap-south-1) |

---

## 📁 Project Structure

```
pipeline-pro/
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions CI/CD pipeline
├── app/
│   └── app.py                # Flask application
├── terraform/
│   ├── main.tf               # VPC, Subnet, IGW, Route Table, SG, EC2
│   ├── variables.tf          # Input variables (region, AMI, instance type, my-ip)
│   ├── outputs.tf            # Outputs (EC2 public IP)
│   └── terraform.tfvars      # Variable values (gitignored)
├── Dockerfile                # Container image definition
├── requirements.txt          # Python dependencies (flask)
└── README.md
```

---

## ⚙️ How It Works

### 1. Infrastructure — Terraform

All AWS resources are defined as code in `/terraform`:

- **VPC** with a CIDR block and DNS support enabled
- **Public Subnet** in `ap-south-1a`
- **Internet Gateway** attached to the VPC
- **Route Table** routing `0.0.0.0/0` through the IGW
- **Security Group** allowing SSH (port 22, restricted to `my-ip`) and HTTP (port 80, open)
- **EC2 Instance** (Amazon Linux 2) with a key pair for SSH access

Provision infrastructure:

```bash
cd terraform
terraform init
terraform plan -var="my_ip=<YOUR_IP>/32"
terraform apply -var="my_ip=<YOUR_IP>/32"
```

### 2. App — Flask

A minimal Flask app served on port `5000` inside the container.

Run locally:

```bash
pip install -r requirements.txt
python app/app.py
```

### 3. Container — Docker

```bash
# Build
docker build -t pipeline-pro .

# Run
docker run -p 5000:5000 pipeline-pro
```

Visit `http://localhost:5000`

### 4. CI/CD — GitHub Actions

On every push to `main`, the workflow:

1. Lints Python code with flake8
2. Builds Docker image and pushes to GHCR
3. Runs terraform apply to provision EC2 on AWS
4. SSHs into EC2, pulls image, runs container

**Required GitHub Secrets:**

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key |

---

## 🚦 Getting Started

### Prerequisites

- AWS account with IAM user credentials configured (`aws configure`)
- Terraform ≥ 1.0 installed
- Docker installed
- GitHub repository with Secrets configured

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/X-Prashant-Verma/pipeline-pro.git
cd pipeline-pro

# 2. Add GitHub Secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

# 3. Push to main — GitHub Actions handles the rest
git push origin main
```

---

## 🔐 Security Notes

- AWS credentials are never hardcoded — passed via `aws configure` or environment variables
- Sensitive values (`terraform.tfvars`, `.env`) are gitignored

---

## 📚 What I Learned

- Provisioning production-style AWS networking (VPC, Subnet, IGW, Route Tables) with Terraform
- Writing reusable Terraform modules with input variables and outputs
- Building multi-stage Docker images and pushing to GHCR
- Wiring end-to-end CI/CD with GitHub Actions — from code push to live deployment
- Managing secrets securely across GitHub Actions and AWS

---

## 🗺️ Part of My DevOps Roadmap

| Phase | Project | Status |
|---|---|---|
| 1 — Linux/Bash | LogHunter | ✅ Done |
| 2 — AWS CLI | LambdaNotify | ✅ Done |
| 3 — Kubernetes | ZeroDown | ✅ Done |
| **4 — IaC + CI/CD** | **PipelinePro** | ✅ Done |
| 5 — AIOps | MLSentinel | ⏳ Upcoming |

---

## 👤 Author

**Prashant Verma**  
Cloud & DevOps Engineer in the making  
[LinkedIn](https://www.linkedin.com/in/x-prashant-verma) · [GitHub](https://github.com/X-Prashant-Verma)