# Application.mk
# Copyright (c) 2012 Jacek Marchwicki
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The ARMv7 is significanly faster due to the use of the hardware FPU
APP_ABI := all
#APP_ABI := armeabi-v7a  armeabi x86
#APP_ABI  := x86
#APP_ABI := armeabi-v7a
APP_PLATFORM := android-9
#APP_OPTIM := debug