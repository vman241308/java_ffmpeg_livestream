/*
 * nativetester.h
 * Copyright (c) 2012 Jacek Marchwicki
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#ifndef NATIVETESTER_H_
#define NATIVETESTER_H_

static const char *nativetester_class_path_name = "com/appunite/ffmpeg/NativeTester";

jboolean jni_nativetester_is_neon(JNIEnv *env, jobject thiz);
jboolean jni_nativetester_is_vfpv3(JNIEnv *env, jobject thiz);


static JNINativeMethod nativetester_methods[] = {
		{"isNeon", "()Z", (void*) jni_nativetester_is_neon},
		{"isVfpv3", "()Z", (void*) jni_nativetester_is_vfpv3},
};

#endif /* NATIVETESTER_H_ */
