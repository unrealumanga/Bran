import ollama
import click
import time
from pathlib import Path

# Common conversational fluff words to check for
FLUFF_WORDS = [
    "Certainly",
    "Of course",
    "Here is",
    "Here's",
    "Sure",
    "I can help",
    "I'd be happy",
    "Absolutely",
    "Definitely",
]


def count_fluff(text: str) -> int:
    """Counts the occurrences of fluff words in a response."""
    count = 0
    text_lower = text.lower()
    for word in FLUFF_WORDS:
        if word.lower() in text_lower:
            count += 1
    return count


def run_test(client, model, prompt, system_prompt=None):
    """Runs a single test against the Ollama model."""
    messages = [{"role": "user", "content": prompt}]
    if system_prompt:
        messages.insert(0, {"role": "system", "content": system_prompt})

    start_time = time.time()
    try:
        response = client.chat(model=model, messages=messages)
        end_time = time.time()

        content = response["message"]["content"]
        fluff_count = count_fluff(content)
        duration = end_time - start_time

        return {
            "content": content,
            "fluff_count": fluff_count,
            "duration": duration,
            "error": None,
        }
    except Exception as e:
        return {"error": str(e)}


@click.command()
@click.option(
    "--model", default="llama3:latest", help="The Ollama model to test against."
)
@click.option("--prompt", required=True, help="The test prompt to send.")
@click.option(
    "--bran-path",
    default="../CLAUDE.md",
    help="Path to the Bran system prompt (CLAUDE.md).",
)
def main(model, prompt, bran_path):
    """Benchmarks the fluff-reduction of a Bran-ified system prompt."""
    try:
        client = ollama.Client()
        # Check if model exists
        client.show(model)
    except Exception as e:
        click.echo(
            f"Error connecting to Ollama or finding model '{model}': {e}", err=True
        )
        click.echo(
            "Please ensure the Ollama server is running and the model is installed.",
            err=True,
        )
        return

    bran_prompt_path = Path(bran_path)
    if not bran_prompt_path.exists():
        click.echo(
            f"Error: Bran prompt file not found at '{bran_prompt_path}'", err=True
        )
        return

    bran_system_prompt = bran_prompt_path.read_text()

    click.echo(f"Running benchmark on model: {click.style(model, bold=True)}")
    click.echo("-" * 40)

    # Test 1: Baseline (no system prompt)
    click.echo("1. Running baseline test (no system prompt)...")
    baseline_result = run_test(client, model, prompt)
    if baseline_result["error"]:
        click.echo(f"   {click.style('Error:', 'red')} {baseline_result['error']}")
        return
    click.echo(f"   - Fluff words: {baseline_result['fluff_count']}")
    click.echo(f"   - Duration: {baseline_result['duration']:.2f}s")

    # Test 2: With Bran system prompt
    click.echo("\n2. Running Bran-ified test...")
    bran_result = run_test(client, model, prompt, system_prompt=bran_system_prompt)
    if bran_result["error"]:
        click.echo(f"   {click.style('Error:', 'red')} {bran_result['error']}")
        return
    click.echo(f"   - Fluff words: {bran_result['fluff_count']}")
    click.echo(f"   - Duration: {bran_result['duration']:.2f}s")

    click.echo("-" * 40)

    # Calculate and display results
    fluff_reduction = int(baseline_result["fluff_count"]) - int(
        bran_result["fluff_count"]
    )

    if int(baseline_result["fluff_count"]) > 0:
        reduction_percent = (
            fluff_reduction / int(baseline_result["fluff_count"])
        ) * 100
        click.echo(
            f"Fluff Reduction: {click.style(f'{reduction_percent:.1f}%', 'green', bold=True)} ({baseline_result['fluff_count']} -> {bran_result['fluff_count']})"
        )
    else:
        click.echo(f"Fluff Reduction: N/A (baseline had no fluff)")

    click.echo("\nBaseline Response Preview:")
    click.echo(click.style(f"> {baseline_result['content'][:200]}...", "yellow"))
    click.echo("\nBran-ified Response Preview:")
    click.echo(click.style(f"> {bran_result['content'][:200]}...", "cyan"))


if __name__ == "__main__":
    main()
