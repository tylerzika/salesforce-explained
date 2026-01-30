# Contributing to Salesforce Sales Cloud Best Practices

Thank you for your interest in contributing to this educational resource! This project aims to demonstrate Sales Cloud best practices for global sales operations.

## How to Contribute

### Reporting Issues
If you find any issues with the metadata or documentation:
1. Check if the issue already exists in the GitHub Issues
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce (if applicable)
   - Expected vs. actual behavior
   - Salesforce CLI and API version information

### Suggesting Enhancements
We welcome suggestions for additional Sales Cloud features or best practices:
1. Open a new issue with the "enhancement" label
2. Describe the feature and its business value
3. Explain how it demonstrates Sales Cloud best practices
4. Include any relevant Salesforce documentation links

### Submitting Changes

#### Before You Start
- Ensure your changes align with Sales Cloud best practices
- Use declarative features whenever possible (Flow, Process Builder, Approval Processes)
- Avoid custom Apex code unless absolutely necessary
- Test your changes in a scratch org

#### Making Changes
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following the guidelines below
4. Test your changes in a scratch org
5. Update documentation (README.md, DEPLOYMENT.md) as needed
6. Commit with clear, descriptive messages
7. Push to your fork
8. Create a Pull Request

#### Code Standards

**Metadata Naming Conventions:**
- Use clear, descriptive names
- Follow Salesforce naming conventions
- Use underscores for custom fields: `Field_Name__c`
- Use spaces for labels: "Field Name"

**Flow Best Practices:**
- Use descriptive flow names
- Add descriptions to all flows
- Include error handling where appropriate
- Follow Salesforce flow best practices

**Report & Dashboard Standards:**
- Store in appropriate folders
- Use descriptive names
- Include descriptions
- Set appropriate access levels

**Documentation:**
- Update README.md for user-facing changes
- Update DEPLOYMENT.md for setup changes
- Use clear, concise language
- Include screenshots for UI changes

#### Pull Request Process
1. Ensure all metadata deploys successfully to a scratch org
2. Update the README.md with details of changes
3. Update the DEPLOYMENT.md if setup steps change
4. Reference any related issues in the PR description
5. Request review from maintainers

### What We're Looking For

Contributions should focus on:
- ✅ Standard Salesforce features (no custom code)
- ✅ Declarative automation (Flows, Approval Processes)
- ✅ Reports and dashboards for sales analytics
- ✅ Multi-currency and global setup configurations
- ✅ Sales Cloud best practices documentation
- ✅ Educational value for learners

We prefer NOT to include:
- ❌ Custom Apex code (unless essential)
- ❌ Third-party integrations
- ❌ Non-Sales Cloud features
- ❌ Complex custom solutions

## Development Setup

1. **Install Salesforce CLI**
   ```bash
   npm install -g @salesforce/cli
   ```

2. **Clone the Repository**
   ```bash
   git clone https://github.com/tylerzika/salesforce-explained.git
   cd salesforce-explained
   ```

3. **Authenticate with Dev Hub**
   ```bash
   sf org login web --set-default-dev-hub
   ```

4. **Create a Scratch Org**
   ```bash
   sf org create scratch --definition-file config/project-scratch-def.json --alias dev-org --set-default
   ```

5. **Deploy Your Changes**
   ```bash
   sf project deploy start
   ```

6. **Open the Org**
   ```bash
   sf org open
   ```

## Testing Your Changes

Before submitting a PR, test:
1. Deploy to a fresh scratch org
2. Test lead conversion functionality
3. Test approval process with high-value opportunity
4. Verify all reports display correctly
5. Check dashboard components load properly
6. Test territory assignments (if modified)
7. Verify multi-currency functionality

## Documentation

When adding new features, document:
- Purpose and business value
- Configuration steps
- Use cases
- Best practices demonstrated
- Any manual post-deployment steps

## Questions?

If you have questions about contributing:
- Review the [README.md](README.md)
- Check [Salesforce Documentation](https://help.salesforce.com/)
- Ask on [Salesforce StackExchange](https://salesforce.stackexchange.com/)

## Code of Conduct

- Be respectful and constructive
- Focus on educational value
- Follow Salesforce best practices
- Help others learn

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for helping make this a valuable educational resource!
