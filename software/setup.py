from setuptools import setup, find_packages

setup(
    name="nebkiso",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        line.strip()
        for line in open("requirements.txt")
        if line.strip() and not line.startswith("#")
    ],
    author="[Author]",
    author_email="[Email]",
    description="NΞBKISØ OLFACTORY SEQUENCER Control Software",
    keywords="olfactory, scent, control-system",
    python_requires=">=3.8",
)
