# Terragrunt Multi-Layer Infrastructure

This repository demonstrates a 3-layer Terragrunt structure with proper dependency management using local modules and null resources.

## Architecture Overview

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│    Layer 2      │  │    Layer 2      │  │    Layer 2      │
│      API        │  │    Frontend     │  │   Analytics     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│    Layer 1      │  │    Layer 1      │  │    Layer 1      │
│    Compute      │  │    Storage      │  │   Monitoring    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
┌─────────────────┐  ┌─────────────────┐
│      Core       │  │      Core       │
│    Network      │  │    Security     │
└─────────────────┘  └─────────────────┘
```

## Directory Structure

```
.
├── terragrunt.hcl              # Root configuration
├── common.tfvars               # Common variables
├── core/                       # Core layer (foundation)
│   ├── network/
│   │   └── terragrunt.hcl
│   └── security/
│       └── terragrunt.hcl
├── layer1/                     # Application layer
│   ├── compute/
│   │   └── terragrunt.hcl
│   ├── storage/
│   │   └── terragrunt.hcl
│   └── monitoring/
│       └── terragrunt.hcl
├── layer2/                     # Service layer
│   ├── api/
│   │   └── terragrunt.hcl
│   ├── frontend/
│   │   └── terragrunt.hcl
│   └── analytics/
│       └── terragrunt.hcl
└── modules/                    # Local Terraform modules
    ├── core-network/
    ├── core-security/
    ├── layer1-compute/
    ├── layer1-storage/
    ├── layer1-monitoring/
    ├── layer2-api/
    ├── layer2-frontend/
    └── layer2-analytics/
```

## Layer Dependencies

### Core Layer (0 dependencies)

- **Network**: Creates VPC, subnets, and basic networking infrastructure
- **Security**: Creates security groups and IAM roles

### Layer 1 (depends on Core)

- **Compute**: Creates compute instances and load balancers (depends on network + security)
- **Storage**: Creates S3 buckets and RDS instances (depends on network + security)
- **Monitoring**: Creates CloudWatch dashboards and log groups (depends on network + security)

### Layer 2 (depends on Layer 1)

- **API**: Creates API Gateway and endpoints (depends on compute + storage)
- **Frontend**: Creates CloudFront distribution and web assets (depends on storage + monitoring)
- **Analytics**: Creates data pipelines and analytics jobs (depends on compute + storage + monitoring)

## Usage

### Deploy entire infrastructure

```bash
# Deploy everything in dependency order
terragrunt run-all apply
```

### Deploy specific layers

```bash
# Deploy core infrastructure first
terragrunt run-all apply --terragrunt-include-dir core

# Deploy layer 1
terragrunt run-all apply --terragrunt-include-dir layer1

# Deploy layer 2
terragrunt run-all apply --terragrunt-include-dir layer2
```

### Deploy individual modules

```bash
# Deploy specific module
cd core/network
terragrunt apply

# Or from root
terragrunt apply --terragrunt-working-dir core/network
```

### Destroy infrastructure

```bash
# Destroy in reverse dependency order
terragrunt run-all destroy
```

## Key Features

1. **Dependency Management**: Each layer properly depends on the previous layer's outputs
2. **Mock Outputs**: Mock values provided for `terragrunt plan` without dependencies
3. **Local Modules**: All modules are local for easy customization and testing
4. **Null Resources**: Uses null resources for demonstration (replace with real resources as needed)
5. **State Management**: Each module has its own state file for isolation
6. **Variable Inheritance**: Common variables shared through root configuration

## Customization

To adapt this structure for real infrastructure:

1. Replace null resources in modules with actual cloud resources
2. Update provider configurations for your cloud platform
3. Modify variables and outputs to match your requirements
4. Add environment-specific configurations
5. Configure remote state backend for production use

## Validation

To verify the dependency structure:

```bash
# Generate dependency graph
terragrunt graph-dependencies

# Run plan to see what would be created
terragrunt run-all plan
```
