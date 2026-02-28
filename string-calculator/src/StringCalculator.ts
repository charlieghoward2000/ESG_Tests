export class StringCalculator {
  add(numbers: string): number {
    if (numbers === "") return 0;

    let delimiters: string[] = [",", "\n"]; // custom delimiter
    let numSection = numbers;

    if (numbers.startsWith("//")) {
      const headerEnd = numbers.indexOf("\n"); // find end of delimiter
      const header = numbers.substring(2, headerEnd); // extract delimiters
      numSection = numbers.substring(headerEnd + 1); // extract number section

      if (header.startsWith("[")) {
        const matches = header.match(/\[([^\]]+)\]/g); // find delimiters wrapped in [] and add to array
        if (matches) {
          delimiters = matches.map((m) => m.slice(1, -1)); // remove wrapping [] from elements in array
        }
      } else {
        // single delimiter e.g. ";"
        delimiters = [header];
      }
    }

    const escapedDelimiters = delimiters.map((d) =>
      d.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") // escape any special characters
    );
    const splitRegex = new RegExp(escapedDelimiters.join("|")); // join delimiters with | and then build regex
    const parts = numSection.split(splitRegex); // splits numbers section on any of our dellimiters
    const nums = parts.map((p) => Number(p)); // convert each part to number

    const negatives = nums.filter((n) => n < 0); // extract any negative numbers
    if (negatives.length > 0) {
      throw new Error(`Negatives not allowed: ${negatives.join(",")}`); // create error message
    }

    return nums.filter((n) => n <= 1000).reduce((sum, n) => sum + n, 0); // pass through array and sum numbers
  }
}
