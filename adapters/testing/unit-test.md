# Adapter: Unit Test Strategy

## Decision Tree
1. **Pre-check**: `mvn test-compile ...`
2. **Pass**: `mvn test ...`
3. **Fail (Compile Error)**: Use **Three-Step Workaround**:
   - Compile only dependencies.
   - `javac` specific test class.
   - Run with `junit-platform-console-standalone`.
4. **Fail (Runtime)**: Mark SKIP, guide user to IDE.
