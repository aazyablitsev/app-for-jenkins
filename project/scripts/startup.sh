#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker aazyablicev
sudo systemctl start docker
sudo systemctl enable docker
