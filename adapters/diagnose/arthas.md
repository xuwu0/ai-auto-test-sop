# Adapter: Arthas Diagnosis

## Usage
- **Trace**: `mcporter call arthas.trace class_name=... method_name=...`
- **Stack**: `mcporter call arthas.stack class_name=...`

## HotFix (Redefine)
- Compile modified class: `javac -cp ... -d /tmp/fix File.java`
- Redefine: `mcporter exec -c "java -jar arthas-boot.jar <PID> -c 'redefine /tmp/fix/...class'"`
