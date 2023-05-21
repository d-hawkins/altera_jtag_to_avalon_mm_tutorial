/* ----------------------------------------------------------------
 * jtag_client.c
 *
 * 3/10/2012 D. W. Hawkins (dwh@caltech.edu)
 *
 * JTAG-to-Avalon-MM client command-line interface.
 *
 * ----------------------------------------------------------------
 * Notes:
 * ------
 *
 * 1. Windows Cygwin build:
 *
 *    gcc -Wall -o jtag_client jtag_client.c
 *
 * ----------------------------------------------------------------
 */
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <string.h>
#include <errno.h>

/* Usage */
static void show_usage()
{
	printf(
		 "\n"\
		 "JTAG-to-Avalon-MM client\n"\
		 "------------------------\n\n"\
		 "Usage: jtag_client [options]\n"\
		 "  -h | --help                Help (this message)\n"\
		 "\n"\
		 "Server::\n"\
		 "  -n | --hostname <hostname> Hostname or IP of server.\n"\
		 "  -p | --port <port>         Server port number.\n"
		 "JTAG Read:\n"\
		 "  -r | --read  <address>     Read address\n"\
		 "\n"\
		 "JTAG Write:\n"\
		 "  -w | --write <address>     Write address\n"\
		 "  -d | --data <data>         Write data (32-bit)\n"\
		 "\n"\
		 "Note: the Avalon-MM read/write addresses are byte-based\n"\
		 "      so the address value should be 32-bit aligned.\n"\
		 "\n");
}

int main(int argc, char *argv[])
{
	int status;

	/* Sockets variables */
    int    fd;
    int    len;
    struct sockaddr_in sockaddr;
    struct in_addr inaddr;
    struct hostent *host;
    char buffer[80];
    int buflen;

	/* Command-line argument parsing */
	int opt;
	int option_index = 0;
	static struct option long_options[] = {
		/* Long and short options */
		{"data",     1, 0, 'd'},
		{"help",     0, 0, 'h'},
		{"hostname", 1, 0, 'n'},
		{"port",     1, 0, 'p'},
		{"read",     1, 0, 'r'},
		{"write",    1, 0, 'w'},
		{0, 0, 0, 0}
	};
	char *hostname = NULL;    /* default to localhost */
	unsigned int port = 2540; /* default port number */
	unsigned int data = 0;
	unsigned int data_valid = 0;
	unsigned int address;
	unsigned int address_valid = 0;
	unsigned int write_command = 0;

	while ((opt = getopt_long(
		argc, argv, "d:hn:p:r:w:", long_options, &option_index)) != -1) {
		switch (opt) {
			/* Long and short options */

			case 'd':
				if ( (optarg[0] == '0') &&
					((optarg[1] == 'x') || (optarg[1] = 'X')) ) {
					/* scan hex */
					status = sscanf(optarg, "%x", &data);
				} else {
					/* scan decimal */
					status = sscanf(optarg, "%d", &data);
				}
				if (status < 0) {
					printf("Error: invalid data argument\n");
					return -1;
				}
				data_valid = 1;
				break;

			case 'h':
				show_usage();
				return -1;

			case 'n':
				hostname = optarg;
				break;


			case 'p':
				if ( (optarg[0] == '0') &&
					((optarg[1] == 'x') || (optarg[1] = 'X')) ) {
					/* scan hex */
					status = sscanf(optarg, "%x", &port);
				} else {
					/* scan decimal */
					status = sscanf(optarg, "%d", &port);
				}
				if (status < 0) {
					printf("Error: invalid server port argument\n");
					return -1;
				}
				break;

			case 'r':
				if ( (optarg[0] == '0') &&
					((optarg[1] == 'x') || (optarg[1] = 'X')) ) {
					/* scan hex */
					status = sscanf(optarg, "%x", &address);
				} else {
					/* scan decimal */
					status = sscanf(optarg, "%d", &address);
				}
				if (status < 0) {
					printf("Error: invalid address argument\n");
					return -1;
				}
				address_valid = 1;
				break;

			case 'w':
				if ( (optarg[0] == '0') &&
					((optarg[1] == 'x') || (optarg[1] = 'X')) ) {
					/* scan hex */
					status = sscanf(optarg, "%x", &address);
				} else {
					/* scan decimal */
					status = sscanf(optarg, "%d", &address);
				}
				if (status < 0) {
					printf("Error: invalid address argument\n");
					return -1;
				}
				address_valid = 1;
				write_command = 1;
				break;

			default:
				show_usage();
				return -1;
		}
	}

	if (!address_valid) {
		printf("Error; a valid address must be supplied.\n");
		printf("Use --help to see the correct usage.\n");
		return -1;
	}

	if ((address & ~0x3) != address) {
		printf("Error; the address must be 32-bit aligned\n");
		printf("Use --help to see the correct usage.\n");
		return -1;
	}

	if (write_command && !data_valid) {
		printf("Error; valid write data must be supplied\n");
		printf("Use --help to see the correct usage.\n");
		return -1;
	}

	/* ------------------------------------------------------------
	 * Client-to-server connection
	 * ------------------------------------------------------------
	 */
  	/* If the hostname can be converted to an IP, do so.
	 * If not, try to look it up in DNS.
	 */
	if (hostname != NULL) {
	    if (inet_pton(AF_INET, hostname, &inaddr)) {
   			host = gethostbyaddr(
				(char *)&inaddr, sizeof(inaddr), AF_INET);
		} else {
	   	    host = gethostbyname(hostname);
		}
	   	if (host == NULL) {
			/* We can't find an IP number */
	   	    printf("Error; failed to find the IP of the server\n");
			return -1;
	   	}
	}

	/* Create a socket for the client */
    fd = socket(AF_INET, SOCK_STREAM, 0);
	if (fd < 0) {
		printf("Error; socket creation failed : %s\n", strerror(errno));
		return 1;
	}

	/* Name the socket */
    sockaddr.sin_family = AF_INET;
	if (hostname == NULL) {
		sockaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
	} else {
		/* Take the first IP address associated with this hostname */
    	memcpy(&sockaddr.sin_addr, host->h_addr_list[0],
				sizeof(sockaddr.sin_addr));
	}
    sockaddr.sin_port = htons(port);
    len = sizeof(sockaddr);

	/* Now connect our socket to the server's socket */
	printf("Connect to server %s:%d\n", (hostname == NULL) ? "localhost" : hostname, port);
	status = connect(fd, (struct sockaddr *)&sockaddr, len);
    if (status < 0) {
   		printf("Error; socket connect failed : %s\n", strerror(errno));
   		printf("Please check that the JTAG server is running.\n");
		return 1;
    }

	/* ------------------------------------------------------------
	 * Client-to-server command strings
	 * ------------------------------------------------------------
	 */

	/* Format the ASCII command
	 *
	 * A while loop is used so that the 'break' command can be
	 * used to drop out of the processing sequence if an error
	 * occurs.
	 */
	while (1) {
		if (write_command == 0) {
			buflen = snprintf(buffer, 79, "jtag_read 0x%.8X\n", address);
			if (buflen < 0) {
				printf("Error; string formatting failed - %s.\n",
						strerror(errno));
				/* Break and close the socket */
				break;
			}

			/* Send the command */
			len = write(fd, buffer, buflen);
			if (len == 0) {
				printf("EOF detected, disconnecting.\n");
				/* Break and close the socket */
				break;
			}
			if (len < 0) {
				printf("Error; socket write failed - %s.\n",
						strerror(errno));
				/* Break and close the socket */
				break;
			}

			/* Read the response data (10 ASCII characters) */
			len = read(fd, buffer, 10);
			if (len == 0) {
				printf("EOF detected, disconnecting.\n");
				/* Break and close the socket */
				break;
			}
			if (len < 0) {
				printf("Error; socket read failed - %s.\n",
						strerror(errno));
				/* Break and close the socket */
				break;
			}

			/* Terminate the string */
			buffer[10] = 0;

			/* Parse the response data */
			status = sscanf(buffer, "%x", &data);
			if (status < 0) {
				printf("Error: scanning the response data failed\n");
				/* Break and close the socket */
				break;
			}

			/* Successfully read the response */
			break;

		} else {
			buflen = snprintf(buffer, 80, "jtag_write 0x%.8X 0x%.8X\n", address, data);
			if (buflen < 0) {
				printf("Error; string formatting failed - %s.\n",
						strerror(errno));
				/* Break and close the socket */
				break;
			}

			/* Send the command */
			len = write(fd, buffer, buflen);
			if (len == 0) {
				printf("EOF detected, disconnecting.\n");
				/* Break and close the socket */
				break;
			}
			if (len < 0) {
				printf("Error; socket write failed - %s.\n",
						strerror(errno));
				/* Break and close the socket */
				break;
			}

			/* No response expected for the write command */
			break;
		}
	}
	close(fd);

	/* ------------------------------------------------------------
	 * Command
	 * ------------------------------------------------------------
	 */
	if (write_command == 0) {
		printf("JTAG read (address, data) = (0x%.8X, 0x%.8X)\n", address, data);
	} else {
		printf("JTAG write (address, data) = (0x%.8X, 0x%.8X)\n", address, data);
	}
	return 0;
}

