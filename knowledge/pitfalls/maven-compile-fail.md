# Pitfall: Maven Compile Failure

## Symptom
`mvn test` fails with errors about missing classes (e.g., `LesCptMockDiamondConfig`), even though code looks correct.

## Root Cause
The project has existing compilation errors in other modules (not related to the current change), preventing Maven from compiling the whole project.

## Solution
Use the "Three-Step Workaround" defined in `adapters/testing/unit-test.md`:
1. Compile only the specific module dependencies (skipping errors).
2. Use `javac` to compile just the test class.
3. Run with `junit-platform-console-standalone`.

## Applicable Scenarios
- Multi-module projects with legacy build errors.
- Automated CLI testing where IDE incremental compilation is not available.
