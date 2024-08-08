# Pull Request Testing Requirements

Testing is a critical aspect of the pull request process for the development
here at Paradise. Bugs often arise due to insufficient testing, which
can compromise the hard work of our contributors and development team members.
It is mandatory that all pull requests undergo thorough testing before merging.
Failure to comply may result in closure of the pull request and possible
disciplinary action.

## Testing Procedures

### Local Testing

1. Compile and Run: Ensure the code compiles without errors.

2. Game Loading: Use your preferred debugging method to load the game and verify
   changes are applied correctly.

3. Functional Testing: Test new features or changes to ensure they integrate
   smoothly with existing functionality.

### Validation

1. Feature Integrity: Confirm that new additions do not break existing game
   features.

2. Performance Testing: Assess the performance impact of changes to ensure they
   meet acceptable standards.

### Comprehensive Review

1. Edge Cases: Test edge cases to ensure robustness of the code.

2. Error Handling: Verify error handling mechanisms are effective and
   informative.

### Documentation and Reporting

1. Update Documentation: If changes impact user-facing features or developer
   documentation, update them accordingly.

2. Reporting: Provide clear and concise feedback in the pull request regarding
   testing outcomes and any discovered issues.

### Test Merging Into Production

1. Additional Testing: If further validation is necessary, a test merge into
   production may be scheduled to assess the code in a live environment. It is
   imperative that the code functions correctly before proceeding with a test
   merge.

2. Requesting a Test Merge: Authors of pull requests may request a test merge
   during the review phase. Additionally, development team members may initiate
   a test merge if deemed necessary.

3. Responsibilities During Test Merge: If your pull request is selected for a
   test merge, it is your responsibility to actively manage and update it as
   needed for integration into the codebase. This includes promptly addressing
   reported bugs and related issues.

4. Consequences of Non-compliance: Failure to address requested changes during
   the test merge process will result in the pull request being reverted from
   production and potentially closed.

Testing plays a vital role in our process. As an open-source project with a
diverse community of contributors, it's essential to safeguard everyone's
contributions from potential issues. Thorough testing not only helps maintain
the quality of our code but also eases the workload for our development team,
who ensure that each pull request meets our agreed-upon standards. By following
these steps, we can ensure a streamlined process when implementing changes.

Do you need some help with testing your Pull Request? You can ask questions to
the development team on the [Paradise Station Discord][discord]. We also have a
[guide about testing pull requests here!][testing-guide]

[discord]: https://discord.gg/YJDsXFE
[testing-guide]: testing_guide.md
