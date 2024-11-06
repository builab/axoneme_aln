# Axoneme_aln Installation Guide

This guide provides step-by-step instructions to install **Axoneme_aln** along with its required dependencies and configuration.

## Required External Packages

- [**Bsoft**](https://cbiit.github.io/Bsoft/)
- [**Spider**](https://github.com/spider-em/SPIDER)
- **TOM box** (now contained in the distribution)

---

## Installing Axoneme_aln

1. **Download the Archive File**  
   Download `aa.tar.gz` (Axoneme_aln archive file) to your local machine.

2. **Create Installation Directory**  
   Replace `$AA_DIR` with your preferred installation directory (e.g., `/usr/local/axoneme_aln`).

   ```bash
   mkdir $AA_DIR
   cp aa.tar.gz $AA_DIR
   cd $AA_DIR
   tar -xvf aa.tar.gz

