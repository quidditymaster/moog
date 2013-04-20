from distutils.core import setup
import os
import sys
import fileinput
import platform
import subprocess

from platform import system as current_platform
from shutil import copy, move, copytree
from glob import glob

# Distutils setup information
setup(
    name='moog',
    version='2013.02',
    author='Chris Sneden',
    author_email='chris@verdi.as.utexas.edu',
    maintainer='Andy Casey',
    maintainer_email='andy@the.astrowizici.st',
    url='http://www.as.utexas.edu/~chris/moog.html',
    download_url='http://github.com/andycasey/moog',
    description='Spectrum synthesis and LTE line analysis.',
    long_description='MOOG is a code that performs a variety of LTE line '  \
    +'analysis and spectrum synthesis tasks. The typical use of MOOG is to' \
    +'assist in the determination of the chemical composition of a star.',
    keywords='high-resolution, stellar, spectroscopy, astronomy, astrophysics',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: MacOS X',
        'Environment :: X11 Applications',
        'Intended Audience :: Science/Research',
        'Natural Language :: English',
        'Operating System :: MacOS',
        'Operating System :: POSIX',
        'Operating System :: Unix',
        'Programming Language :: Fortran',
        'Programming Language :: Python :: 2.5',
        'Topic :: Scientific/Engineering :: Astronomy',
        'Topic :: Scientific/Engineering :: Physics',
    ]
    )


# Identify the platform
platform = current_platform()

# Check for platform first
if platform not in ('Darwin', 'Linux'):
    sys.stderr.write("Platform '%s' not recognised!\n" % platform)
    sys.exit()


if os.getuid() != 0:
    sys.stderr.write("Permission denied: Sudo access is required!\n")
    sys.exit()

# We are sudo; with great power comes great responsibility.

# By default, we will use 32bit 
is_64bits = False

# Which system are we on?
if platform == 'Darwin':
    run_make_files = ('Makefile.mac', 'Makefile.macsilent')
    machine = 'mac'

elif platform == 'Linux':

    machine = 'pcl'
    is_64bits = sys.maxsize > 2**32

    if is_64bits:
        run_make_files = ('Makefile.rh64', 'Makefile.rh64silent')

    else:
        run_make_files = ('Makefile.rh', 'Makefile.rhsilent')


# Check for gfortran or g77
def system_call(command):
    """ Perform a system call with a subprocess pipe """
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
    return process.communicate()[0]

# Look for g77 and gfortran
g77_exists = len(system_call("which g77")) > 0
gfortran_exists = len(system_call("which gfortran")) > 0

# If we have the choice, use gfortran
if gfortran_exists:

    if is_64bits:
        fortran_vars = "FC = gfortran -m64\nFFLAGS = -Wall -O4 -ffixed-line-length-72 -ff2c"

    else:
        fortran_vars = "FC = gfortran\nFFLAGS = -Wall -O4 -ffixed-line-length-72 -ff2c"

elif g77_exists:
    
    if platform == 'Linux':
        fortran_vars = 'FC = g77 -Wall'

    else:
        fortran_vars = 'FC = g77 -w'
    
else:
    sys.stderr.write("Could not find g77 or gfortran on the system!\n")
    sys.exit()

# Get our directories relative to the current path
repository_dir = os.path.dirname(os.path.realpath(__file__))

# Write the configure file
src_dir = os.path.join(repository_dir, 'moog')
aqlib = "AQLIB = %s" % os.path.join(repository_dir, 'lib/aqlib')
smlib = "SMLIB = %s" % os.path.join(repository_dir, 'lib/smlib')

configuration = "\n".join([fortran_vars, aqlib, smlib])

# Update the makefiles with the proper SMLIB and AQLIB
run_make_files = [os.path.join(repository_dir, 'moog', filename) for filename in run_make_files]
hardcoded_moog_files = [os.path.join(repository_dir, 'moog', filename) for filename in ('Moog.f', 'Moogsilent.f')]

# Setup: Move and create copies of the original
for make_file in run_make_files:
    move(make_file, make_file + '.original')
    copy(make_file + '.original', make_file)

for moog_file in hardcoded_moog_files:
    move(moog_file, moog_file + '.original')
    copy(moog_file + '.original', moog_file)


# Update the run make files with the configuration
for line in fileinput.input(run_make_files, inplace=True):
    line = line.replace('#$CONFIGURATION', configuration)

    sys.stdout.write(line)

# Update the MOOG files
for line in fileinput.input(hardcoded_moog_files, inplace=True):
    line = line.replace('$SRCDIR', src_dir)
    line = line.replace('$MACHINE', machine)

    sys.stdout.write(line)

# Run the appropriate make files
for make_file in run_make_files:
    os.system('cd moog;make -f %s' % make_file)

# Cleanup files: Replace with original files
[move(moog_file + '.original', moog_file) for moog_file in hardcoded_moog_files if os.path.exists(moog_file + '.original')]
[move(make_file + '.original', make_file) for make_file in run_make_files if os.path.exists(make_file + '.original')]

# Copy the AquaTerm framework
try:
    copytree(os.path.join(repository_dir, 'lib/AquaTerm.framework'), '/Library/Frameworks/AquaTerm.framework')

except:
    sys.stdout.write("AquaTerm framework could not be installed to /Library/Frameworks/AquaTerm.framework\n")

else:
    sys.stdout.write("AquaTerm framework copied to /Library/Frameworks/AquaTerm.framework\n")

# Copy the MOOG & MOOGSILENT to /usr/local/bin/
try:
    copy(os.path.join(src_dir, 'MOOG'), '/usr/local/bin/MOOG')
    copy(os.path.join(src_dir, 'MOOGSILENT'), '/usr/local/bin/MOOGSILENT')

    system_call('chmod 755 /usr/local/bin/MOOG')
    system_call('chmod 755 /usr/local/bin/MOOGSILENT')

except:
    sys.stdout.write("Could not copy MOOG and MOOGSILENT to /usr/local/bin/ and/or make them executable\n")

else:
    sys.stdout.write("MOOG and MOOGSILENT installed to /usr/local/bin/\n")


