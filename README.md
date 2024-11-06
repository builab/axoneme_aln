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
   Replace `$AA_DIR` with your preferred installation directory (e.g., `/storage/software/axoneme_aln`).

   ```bash
   mkdir $AA_DIR
   cp aa.tar.gz $AA_DIR
   cd $AA_DIR
   tar -xvf aa.tar.gz

---

## Configuration

### 1. Set Environment Paths

   Edit the source files based on your preferred shell:

   - **For C-shell**: Edit `$AA_DIR/axoneme_aln.cshrc`
     ```csh
     setenv AA_DIR /storage/software/axoneme_aln  # replace with actual path
     ```
   - **For Bash shell**: Edit `$AA_DIR/axoneme_aln.bashrc`
     ```bash
     export AA_DIR=/storage/software/axoneme_aln  # replace with actual path
     ```

### 2. Link or Alias Spider Executable

   Locate the Spider executable in `$SPIDER_DIR/bin` (e.g., `spider_linux_mp_intel64`) and link it to `spider`:

   ```bash
   ln -s spider_linux_mp_intel64 spider
   ```

   If you lack permission to create this link, create an alias in your source file:

   - **C or TCSH shell**: Add to `~/.cshrc`
     ```csh
     alias spider_linux_mp_intel64='spider'
     ```
   - **Bash shell**: Add to `~/.bashrc`
     ```bash
     alias spider_linux_mp_intel64='spider'
     ```

### 3. Add Paths to Startup

   - **For C or TCSH shell**: Add the following to `~/.cshrc`
     ```csh
     setenv PATH $PATH:$SPIDER_DIR/bin
     source $BSOFT_DIR/bsoft.cshrc
     source $AA_DIR/axoneme_aln.cshrc
     ```

   - **For Bash shell**: Add the following to `~/.bashrc`
     ```bash
     export PATH=$SPIDER_DIR/bin:$PATH
     source $BSOFT_DIR/bsoft.bashrc
     source $AA_DIR/axoneme_aln.bashrc
     ```

---

## Installing Parallel::ForkManager Perl Module

To enable parallel processing, install the `Parallel::ForkManager` Perl module:

1. **Download the Module**
   ```bash
   wget http://search.cpan.org/CPAN/authors/id/D/DL/DLUX/Parallel-ForkManager-0.7.5.tar.gz
   ```

2. **Install the Module**
   ```bash
   mv Parallel-ForkManager-0.7.5.tar.gz $AA_DIR/perl
   cd $AA_DIR/perl
   tar -zxvf Parallel-ForkManager-0.7.5.tar.gz
   cd Parallel-ForkManager-0.7.5
   perl Makefile.PL PREFIX=$AA_DIR/perl  # replace $AA_DIR with actual path
   make
   make test
   make install
   ```

You are now ready to use **Axoneme_aln**.
```
