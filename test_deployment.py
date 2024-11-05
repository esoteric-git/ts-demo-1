import unittest
import subprocess
import requests
import json
import time
import os
from typing import Optional

class DeploymentTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Get terraform outputs
        try:
            output = subprocess.check_output(['terraform', 'output', '-json'])
            tf_outputs = json.loads(output)
            cls.vm1_public_ip = tf_outputs['vm1_public_ip']['value']
            cls.vm2_private_ip = tf_outputs['vm2_private_ip']['value']
            cls.django_public_ip = tf_outputs['django_public_ip']['value']
        except Exception as e:
            raise Exception("Failed to get Terraform outputs. Ensure terraform has been applied.") from e

    def _ping(self, host: str, count: int = 3) -> bool:
        """Helper method to ping a host"""
        try:
            subprocess.check_call(
                ['ping', '-c', str(count), host],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            return True
        except subprocess.CalledProcessError:
            return False

    def _ssh_check(self, host: str) -> bool:
        """Helper method to verify SSH connectivity"""
        try:
            subprocess.check_call(
                ['ssh', '-o', 'ConnectTimeout=5', '-o', 'StrictHostKeyChecking=no', 
                 f'ec2-user@{host}', 'echo', 'test'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            return True
        except subprocess.CalledProcessError:
            return False

    def test_01_vm1_ssh_access(self):
        """Test SSH access to VM1"""
        self.assertTrue(
            self._ssh_check('ts-demo-vm1'),
            "Cannot SSH to VM1 via Tailscale name"
        )

    def test_02_django_ssh_access(self):
        """Test SSH access to Django VM"""
        self.assertTrue(
            self._ssh_check('ts-demo-django'),
            "Cannot SSH to Django VM via Tailscale name"
        )

    def test_03_private_vm_ping(self):
        """Test ping to private VM2 through subnet router"""
        self.assertTrue(
            self._ping(self.vm2_private_ip),
            f"Cannot ping VM2 at {self.vm2_private_ip}"
        )

    def test_04_django_app_access(self):
        """Test access to Django application"""
        try:
            response = requests.get('http://ts-demo-django:8000', timeout=5)
            self.assertEqual(response.status_code, 200, "Django app not responding with 200 OK")
        except requests.exceptions.RequestException as e:
            self.fail(f"Failed to connect to Django app: {str(e)}")

if __name__ == '__main__':
    unittest.main(verbosity=2)