import { StringCalculator } from "../src/StringCalculator";

describe("StringCalculator", () => {
  let calc: StringCalculator;

  beforeEach(() => {
    calc = new StringCalculator();
  });

  it("1.i — empty string returns 0", () => {
    expect(calc.add("")).toBe(0);
  });

  it("1.ii — single number returns itself", () => {
    expect(calc.add("1")).toBe(1);
  });

  it("1.iii — two comma-separated numbers return their sum", () => {
    expect(calc.add("1,2")).toBe(3);
  });

  it("2 — more than two numbers", () => {
    expect(calc.add("1,2,3")).toBe(6);
    expect(calc.add("1,2,3,4,5")).toBe(15);
  });

  it("step 3.i — handles newlines as delimiters", () => {
    expect(calc.add("1\n2,3")).toBe(6);
  });

  it("step 3.ii — handles newlines without commas", () => {
    expect(calc.add("1\n2\n3")).toBe(6);
  });

  it("4.i — supports a custom delimiter in the header", () => {
    expect(calc.add("//;\n1;2")).toBe(3);
  });

  it("4.iii — commas and newlines still work when no custom delimiter is set", () => {
    expect(calc.add("1\n2,3")).toBe(6);
  });

  it("5.i — throws for a single negative number", () => {
    expect(() => calc.add("-1,2")).toThrow("Negatives not allowed: -1");
  });

  it("5.ii — lists all negative numbers in the exception", () => {
    expect(() => calc.add("2,-4,3,-5")).toThrow(
      "Negatives not allowed: -4,-5"
    );
  });

  it("6 — numbers greater than 1000 are ignored", () => {
    expect(calc.add("1001,2")).toBe(2);
  });

  it("6 — numbers equal to 1000 are included", () => {
    expect(calc.add("1000,2")).toBe(1002);
  });

  it("7 — supports a multi-character delimiter", () => {
    expect(calc.add("//[|||]\n1|||2|||3")).toBe(6);
  });

  it("8 — supports multiple single-character delimiters", () => {
    expect(calc.add("//[|][%]\n1|2%3")).toBe(6);
  });

  it("9 — supports multiple multi-character delimiters", () => {
    expect(calc.add("//[||][%%]\n1||2%%3")).toBe(6);
  });
});