[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/tyler36/ddev-site-metrics-laravel/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/tyler36/ddev-site-metrics-laravel/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/tyler36/ddev-site-metrics-laravel)](https://github.com/tyler36/ddev-site-metrics-laravel/commits)
[![release](https://img.shields.io/github/v/release/tyler36/ddev-site-metrics-laravel)](https://github.com/tyler36/ddev-site-metrics-laravel/releases/latest)

# DDEV Site Metrics Laravel

## Overview

This add-on integrates Site Metrics Laravel into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get tyler36/ddev-site-metrics-laravel
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Site Metrics Laravel |
| `ddev logs -s site-metrics-laravel` | Check Site Metrics Laravel logs |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.site-metrics-laravel --site-metrics-laravel-docker-image="busybox:stable"
ddev add-on get tyler36/ddev-site-metrics-laravel
ddev restart
```

Make sure to commit the `.ddev/.env.site-metrics-laravel` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `SITE_METRICS_LARAVEL_DOCKER_IMAGE` | `--site-metrics-laravel-docker-image` | `busybox:stable` |

## Credits

**Contributed and maintained by [@tyler36](https://github.com/tyler36)**
