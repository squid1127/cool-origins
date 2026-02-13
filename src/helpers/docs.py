"""Helper script to generate origins documentation"""

from pathlib import Path
import yaml
import json
from dataclasses import dataclass, field

ORIGINS_LOCATIONS = [
    "Origins-Reborn",
    "Origins-Fantasy",
    "Origins-Magic",
    "Origins-Mobs",
    "Origins-Monsters"
]

@dataclass(frozen=True, order=True)
class Origin:
    """Data class representing an origin with its properties and documentation."""
    id: str = field(compare=False)
    friendly_name: str
    source: str
    description: str
    impact: int
    unchoosable: bool = False
    order: int = field(default=0, compare=True)
    ablities: list[str] = field(default_factory=list, compare=False)
    
@dataclass(frozen=True, order=True)
class Ability:
    """Data class representing an ability with its properties and documentation."""
    id: str = field(compare=False)
    friendly_name: str
    description: str

class OriginsDocsGenerator:
    def __init__(self, server: Path):
        """Initializes the OriginsDocsGenerator with the given server path and output path for documentation.
        
        Args:
            server (Path): Path to a paper server directory with origins data
        """
        self.server = server
        
    @property
    def plugins_root(self) -> Path:
        """Returns the path to the plugins root directory if it exists, otherwise raises an error."""
        plugins_path = self.server / "plugins"
        if plugins_path.exists():
            return plugins_path
        raise FileNotFoundError("Plugins root directory does not exist in the server path.")
        
    @property
    def origins_root(self) -> Path:
        """Returns the path to the origins root directory if it exists, otherwise raises an error."""
        origins_path = self.plugins_root / "Origins-Reborn"
        if origins_path.exists():
            return origins_path
        raise FileNotFoundError("Origins root directory does not exist in the server path.")
    
    def collect_origins(self, target: Path) -> list[Origin]:
        """Collects origins from the given target directory and returns a list of Origin objects.
        
        Args:
            target (Path): Path to the directory containing origin JSON files
        Returns:
            list[Origin]: A list of Origin objects representing the collected origins
        """
        
        # Detect source name from the target path
        source_name = target.parent.name
        
        origins = []
        for file in target.glob("*.json"):
            origin_id = file.stem
            with open(file, "r") as f:
                data = json.load(f)
                
                name = data.get("name", None)
                if name is None:
                    # Convert origin ID to a more readable format as a fallback for missing friendly name
                    name = origin_id.replace("_", " ").title()
                
                origin = Origin(
                    id=origin_id,
                    friendly_name=name,
                    source=source_name,
                    description=data.get("description", ""),
                    impact=data.get("impact", 0),
                    unchoosable=data.get("unchoosable", False),
                    order=data.get("order", 0),
                    ablities=data.get("powers", [])
                )
                origins.append(origin)
                
        return origins
    
    def collect_all_origins(self) -> list[Origin]:
        """Collects all origins from the origins root directory and add-on directories and returns a list of Origin objects."""
        
        origins = []
        for location in ORIGINS_LOCATIONS:
            location_path = self.plugins_root / location / "origins"
            if location_path.exists():
                origins.extend(self.collect_origins(location_path))
            else:
                print(f"Warning: Origins location '{location}' does not exist in the server path.")
        return origins
    
    def sort_origins(self, origins: list[Origin]) -> dict[str, list[Origin]]:
        """Sorts the given list of Origin objects by their source and order properties and returns a dictionary mapping source names to sorted lists of Origin objects.
        
        Args:
            origins (list[Origin]): A list of Origin objects to be sorted
        Returns:
            dict[str, list[Origin]]: A dictionary mapping source names to sorted lists of Origin objects
        """
        sorted_origins = {}
        for origin in origins:
            if origin.source not in sorted_origins:
                sorted_origins[origin.source] = []
            sorted_origins[origin.source].append(origin)
        
        # Sort each list of origins by their order property
        for source in sorted_origins:
            sorted_origins[source].sort(key=lambda o: o.order)
        
        return sorted_origins
    
    def collect_abilities(self, translations: Path) -> dict[str, Ability]:
        """Collects abilities from the given translations file and returns a dictionary mapping ability IDs to Ability objects.
        
        Args:
            translations (Path): Path to the translations YAML file containing ability data
        Returns:
            dict[str, Ability]: A dictionary mapping ability IDs to Ability objects
        """
        with open(translations, "r") as f:
            data = yaml.safe_load(f)
            translations_data = data.get("translations", {})
            abilities_data = translations_data.get("abilities", {})
            abilities = {}
            for ability_id, ability_info in abilities_data.items():
                ability = Ability(
                    id=ability_id,
                    friendly_name=ability_info.get("title", ""),
                    description=ability_info.get("description", "")
                )
                abilities[ability_id] = ability
            
        return abilities
    
    def generate_docs(self) -> str:
        """Generates documentation for origins and abilities and returns it as a string.
        
        Returns:
            str: The generated documentation as a string in markdown format
        """
        translations_path = self.plugins_root / "Origins-Reborn" / "translations.yml"
        if not translations_path.exists():
            raise FileNotFoundError("Translations file does not exist in the expected location.")
        
        print("Collecting abilities...")
        abilities = self.collect_abilities(translations_path)
        print(f"Collected {len(abilities)} abilities.")
        
        print("Collecting origins...")
        origins_unsorted = self.collect_all_origins()
        origins = self.sort_origins(origins_unsorted)
        print(f"Collected {len(origins_unsorted)} origins.")
        
        # Generate markdown documentation
        docs = "# List of Origins & Abilities\n\n"
        for source, origins_list in origins.items():
            docs += f"## {source}\n\n"
            for origin in origins_list:
                docs += f"### {origin.friendly_name}\n\n"
                origin_heading = [f"`{origin.id}`"]
                if origin.unchoosable:
                    origin_heading.append("**UNCHOOSABLE**")
                if origin.impact > 0:
                    origin_heading.append(f"({'٭' * origin.impact})")
                    
                docs += " · ".join(origin_heading) + "\n\n"
                
                docs += f"{origin.description}\n\n"
                
                docs += f"**Ablities**: \n"
                
                abilities_list = origin.ablities
                for ability_id in abilities_list:
                    ability = abilities.get(ability_id, None) or abilities.get(f"origins:{ability_id}", None) or abilities.get(f"{ability_id}_display", None)
                    
                    if ability is not None:
                        docs += f"- {ability.friendly_name}: {ability.description}\n"
                    else:
                        docs += f"- `{ability_id}` (Unknown ability)\n"
                if not abilities_list:
                    docs += "- None\n"
                        
                docs += "\n"
                        
        docs += "## All Abilities\n\n"
        for ability in abilities.values():
            docs += f"### {ability.friendly_name}\n\n"
            docs += f"`{ability.id}`\n\n"
            docs += f"{ability.description}\n\n"
            
        return docs
        
if __name__ == "__main__":
    # Run the documentation generator using args from the command line
    import argparse
    parser = argparse.ArgumentParser(description="Generate documentation for Origins mod.")
    parser.add_argument("server_path", type=Path, help="Path to the paper server directory containing origins data.")
    parser.add_argument("output_file", type=Path, help="Path to the output file where the generated documentation will be written.")
    args = parser.parse_args()
    
    generator = OriginsDocsGenerator(args.server_path)
    docs = generator.generate_docs()
    with open(args.output_file, "w") as f:
        f.write(docs)