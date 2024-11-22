from typing import Dict, List, Optional
import logging
from dataclasses import dataclass

from ..database.models import Molecule

logger = logging.getLogger(__name__)

@dataclass
class CompatibilityResult:
    compatible: bool
    reason: str
    risk_level: str  # 'none', 'low', 'medium', 'high'
    max_concentration: float
    safety_notes: str

class ChemistryManager:
    def __init__(self):
        self.molecule_cache: Dict[str, Molecule] = {}
        self.compatibility_matrix: Dict[str, Dict[str, bool]] = {}

    async def check_compatibility(
        self, 
        molecule_id1: str, 
        molecule_id2: str,
        concentration1: float,
        concentration2: float
    ) -> CompatibilityResult:
        """Check compatibility between two molecules."""
        try:
            # Get molecule data
            molecule1 = await self._get_molecule(molecule_id1)
            molecule2 = await self._get_molecule(molecule_id2)
            
            if not molecule1 or not molecule2:
                return CompatibilityResult(
                    compatible=False,
                    reason="One or both molecules not found",
                    risk_level="high",
                    max_concentration=0.0,
                    safety_notes="Invalid molecule combination"
                )
            
            # Check basic compatibility
            if not self._check_basic_compatibility(molecule1, molecule2):
                return CompatibilityResult(
                    compatible=False,
                    reason="Molecules are chemically incompatible",
                    risk_level="high",
                    max_concentration=0.0,
                    safety_notes="Do not mix these molecules"
                )
            
            # Check concentration limits
            max_safe_concentration = min(
                molecule1.max_concentration,
                molecule2.max_concentration
            )
            
            if concentration1 > molecule1.max_concentration or \
               concentration2 > molecule2.max_concentration:
                return CompatibilityResult(
                    compatible=False,
                    reason="Concentration exceeds safe limits",
                    risk_level="high",
                    max_concentration=max_safe_concentration,
                    safety_notes="Reduce concentration to safe levels"
                )
            
            # Calculate combined risk
            risk_level = self._calculate_risk_level(
                molecule1, molecule2,
                concentration1, concentration2
            )
            
            return CompatibilityResult(
                compatible=True,
                reason="Compatible within specified concentrations",
                risk_level=risk_level,
                max_concentration=max_safe_concentration,
                safety_notes=self._generate_safety_notes(
                    molecule1, molecule2,
                    concentration1, concentration2
                )
            )
            
        except Exception as e:
            logger.error(f"Error checking molecule compatibility: {e}")
            return CompatibilityResult(
                compatible=False,
                reason=f"Error in compatibility check: {str(e)}",
                risk_level="high",
                max_concentration=0.0,
                safety_notes="Error occurred during safety check"
            )
