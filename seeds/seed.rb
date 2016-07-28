require 'rom'
require 'rom-sql'

STATUS = [
    'Not started',
    'On hold',
    'In progress',
    'Completed',
    'Abandoned'
]

PLATFORM = ['Create', 'Scale', 'Build']


rom = ROM.container(:mysql, 'sqlite::memory')
