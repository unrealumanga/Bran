import click
import os
import shutil
from pathlib import Path

# Assuming the personas are in the parent directory relative to the bran_cli package
# This will need to be changed to fetch from GitHub when published
PERSONAS_PATH = Path(__file__).parent.parent.parent / "personas"
CLAUDE_GLOBAL_PATH = Path.home() / ".claude"


@click.group()
def cli():
    """A CLI to install and manage Bran (God Mode) persona prompts."""
    pass


@cli.command()
@click.option(
    "--persona",
    default="base",
    help="The persona to install (e.g., trader, blender). 'base' installs the main CLAUDE.md.",
)
@click.option(
    "--scope",
    default="global",
    type=click.Choice(["global", "local"]),
    help="Installation scope: 'global' (~/.claude) or 'local' (./.claude).",
)
def install(persona, scope):
    """Installs a Bran persona."""
    if persona == "base":
        source_file = Path(__file__).parent.parent.parent / "CLAUDE.md"
        dest_filename = "CLAUDE.md"
    else:
        source_file = PERSONAS_PATH / f"bran-{persona}.md"
        dest_filename = f"CLAUDE.{persona}.md"

    if not source_file.exists():
        click.echo(f"Error: Persona '{persona}' not found at {source_file}", err=True)
        return

    if scope == "global":
        dest_path = CLAUDE_GLOBAL_PATH
    else:
        dest_path = Path.cwd() / ".claude"

    dest_path.mkdir(parents=True, exist_ok=True)

    dest_file = dest_path / dest_filename

    try:
        shutil.copy(source_file, dest_file)
        click.echo(f"Successfully installed '{persona}' persona to {dest_file}")
        if scope == "global" and persona != "base":
            click.echo(
                f"To use, you may need to configure your agent to load {dest_filename}"
            )

    except Exception as e:
        click.echo(f"Error installing persona: {e}", err=True)


@cli.command()
def update():
    """Updates the personas from the source (not implemented yet)."""
    click.echo("Update functionality (fetching from git) is not yet implemented.")
    click.echo("Please pull the latest changes from the git repository manually.")


if __name__ == "__main__":
    cli()
